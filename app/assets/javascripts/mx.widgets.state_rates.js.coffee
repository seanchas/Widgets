global = module?.exports ? ( exports ? this )

global.mx           ||= {}
global.mx.widgets   ||= {}

scope = global.mx.widgets

$ = jQuery

cache = kizzy('mx.widgets.state_rates')


locales =
    title:
        auctions:
            ru: 'Средневзвешенные ставки по аукционам Банка России'
            en: 'Weighted Average Rates for Bank of Russia Auctions'
        fixed:
            ru: 'Фиксированные ставки по операциям Банка России'
            en: 'Fixed Rates for Bank of Russia Operations'
    reference:
        fixed:
            ru: '* для депозитов приведены данные по инструменту &laquo;овернайт&raquo;'
            en: '* only overnight deposits are taken'
    days:
        '1_DAY':
            ru: '1 день'
            en: '1 day'
        '1_WEEK':
            ru: '1 неделя'
            en: '1 week'
        '30_DAYS':
            ru: '4 недели'
            en: '4 weeks'
        

data_keys = ['auctions', 'fixed']



make_table = (container) ->
    table = $('<table>')
        .addClass('mx-widget-table mx-widget-state-rates')
        .html('<thead></thead><tbody></tbody>')

    table
        .appendTo(container)


make_table_head_row = (container, columns) ->
    row = $('<tr>')
    
    for column in columns
        $('<td>')
            .addClass(column.type)
            .html(column.short_title)
            .appendTo(row)
    
    row
        .appendTo(container)
    

make_table_body_row = (container, columns, record, index) ->
    row = $('<tr>')
        .toggleClass('even',    index % 2 == 0)
        .toggleClass('odd',     index % 2 == 1)

    for column in columns
        value = record[column.name]
        
        if column.name == 'DAYS'
            value = locales.days[value]?[mx.locale()] || value
        
        $('<td>')
            .addClass(column.type)
            .html(mx.utils.render(value, column) or '&mdash;')
            .appendTo(row)
    
    row
        .appendTo(container)



render = (container, columns, key, data, options = {}) ->
    wrapper = $('<div>')
        .addClass(options.wrapper_class || 'wrapper')
        .appendTo(container)
    
    $('<h4>')
        .html(locales.title[key][mx.locale()])
        .appendTo(wrapper)
    
    table = make_table(wrapper)
    
    table_head = $('thead', table)
    table_body = $('tbody', table)
    
    make_table_head_row(table_head, columns)
    
    make_table_body_row(table_body, columns, record, index + 1) for record, index in data

    wrapper.append( $('<p>').addClass('reference').html(locales.reference[key][mx.locale()]) ) if key is 'fixed'



widget = (container, options = {}) ->

    container = $(container) ; return if container.length == 0
    
    ready = $.when(mx.iss.state_rates(), mx.iss.state_rates_columns())


    ready.then (data, columns) ->
        render(container, columns, key, data[key], options) for key in data_keys


_.extend scope,
    state_rates: widget
