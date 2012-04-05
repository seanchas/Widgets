global = module?.exports ? ( exports ? this )

global.mx           ||= {}
global.mx.security  ||= {}

scope = global.mx.security

$ = jQuery


fields = [
    { name: 'SHORT_TITLE',              title: { ru: 'Краткое наименование', en: 'Shortname' } }
    { name: 'TRANSLITERATION_TITLE',    title: { ru: 'Транслитерация'      , en: 'Transliteration' } }
    { name: 'LEGAL_ADDRESS',            title: { ru: 'Юридический адрес'   , en: 'Legal address' } }
    { name: 'POSTAL_ADDRESS',           title: { ru: 'Почтовый адрес'      , en: 'Postal address' } }
    { name: 'OKPO',                     title: { ru: 'ОКПО'                , en: 'OKPO' } }
    { name: 'OGRN',                     title: { ru: 'ОГРН'                , en: 'OGRN' } }
    { name: 'INN',                      title: { ru: 'ИНН'                 , en: 'INN' } }
    { name: 'URL',                      title: { ru: 'WEB-адрес'           , en: 'Web' } }
]

url_re = /(\b((https?|ftp|file):\/\/)*([-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|]))/ig

widget = (element, engine, market, board, param, options = {}) ->
    
    element = $(element); return if element.length == 0
    
    create_table = ->
        $("<table>")
            .addClass('mx-security-emitter')
            .html("<thead></thead><tbody></tbody>")


    render = (element, emitter) ->
        table = create_table()

        table_head = $('thead', table)

        table_head.html "<tr><td colspan=\"2\">#{emitter['TITLE']}</td></tr>"

        table_body = $('tbody', table)

        for field in fields
            value = emitter[field.name]
            if value and field.name == 'URL'
                value = value.replace(url_re, (args...) ->
                    schema = args[2] || "http://"
                    domain = args[4].replace(/([^\/])\/$/, "$1")
                    "<a href=\"#{schema + domain}\">#{domain}</a>"
                )
            table_body.append $("<tr><th>#{field.title[mx.locale()]}</th><td>#{value ? '&mdash;'}</td></tr>")

        element.html table

    mx.iss.description(param).then (description) ->
        emitter_id = _.first(field.value for field in description when field.name == 'EMITTER_ID')
        if emitter_id?
            mx.iss.emitter(emitter_id).then (emitter) ->
                if emitter
                    element.trigger('render', { status: 'success' })
                    render element, emitter
                else
                    element.trigger('render', { status: 'failure' })
        else
            element.trigger('render:failure')
    
    {
        destroy: ->
            element.children().remove()
    }


securities_widget = (element, engine, market, board, param, options = {}) ->
    element = $(element); return if element.length == 0
    
    make_url = (r) ->
        if options.url? and _.isFunction(options.url)
            options.url r.engine, r.market, r.boardid, r.secid
        else
            "##{r.engine}:#{r.market}:#{r.boardid}:#{r.secid}"
    
    links = (records) ->
        ids = []
        _.compact (for record in records
            unless _.include ids, record.secid
                ids.push record.secid
                "<a href=\"#{make_url record}\">#{record.secid}</a>"
        )
    
    create_table = ->
        $("<table>")
            .addClass('mx-security-emitter-securities')
            .html("<thead></thead><tbody></tbody>")
    
    create_row = (title, records) ->
        row = $("<tr>")
            .html("<th>#{title}</th><td></td>")
        
        $('td', row)
            .html(links(records).join(", "))
        
        row
    
    render = (data, secids, engines) ->
        table = create_table()
        
        table_body = $('tbody', table)
        
        for engine in engines
            records = _.sortBy _.uniq(data[engine.name]), (record) ->
                _.indexOf secids, record.secid
            
            table_body.append create_row(engine.title, records) if _.size(records) > 0
        
        element.html table
        

    $.when(mx.iss.defaults(), mx.iss.description(param)).then (defaults, description) ->
        emitter_id = _.first(field.value for field in description when field.name == 'EMITTER_ID')
        if emitter_id?
            mx.iss.emitter_securities(emitter_id).then (securities) ->

                ids = _.pluck securities, 'SECID'

                complete    = _.after securities.length, (records) ->
                    if _.size(records) > 0
                        element.trigger('render', { status: 'success' })
                        
                        data = _.reduce _.flatten(records), (memo, record) ->
                            if record.is_traded == 1 and record.secid != param
                                (memo[record.engine] ?= []).push(record)
                            memo
                        , {}
                        
                        render data, _.pluck(securities, 'SECID'), defaults['engines']
                    else
                        element.trigger('render', { status: 'failure' })

                records     = []

                for id in ids
                    mx.iss.boards(id).then (json) ->
                        records.push (record for record in json when record.is_traded == 1)
                        complete records
        else
            element.trigger('render', { status: 'failure' })
    
    {
        destroy: ->
            element.children().remove()
    }

_.extend scope,
    emitter: widget

scope.emitter_securities = securities_widget
