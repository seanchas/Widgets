global = module?.exports ? ( exports ? this )

global.mx           ||= {}
global.mx.widgets   ||= {}

scope = global.mx.widgets

$ = jQuery

link_given_date    = mx.iss.iss_host + "/statistics/engines/stock/mmakers/ranks"
link_entire_period = mx.iss.iss_host + "/statistics/engines/stock/mmakers/ranks/alltime"
link_params        = "&lang=#{mx.locale()}&iss.only=ranks&ranks.columns=TRADEDATE,SECID,RANK,VALUE,IS_THRESHOLD_AMOUNT"

localization =
    ru:
        datepicker_locale: "ru"
        csv_options_link:  "&or;"
        csv_options_title: "Параметры выгрузки CSV"
        dp_label:          "Разделитель для десятичных знаков:"
        dp_options:        [
            [",", "(,) запятая"]
            [".", "(.) точка"]
        ]
        dl_label:          "Разделитель полей:"
        dl_options:        [
            [";", "(;) точка с запятой"]
            [",", "(,) запятая"]
        ]
        df_label:          "Формат даты:"
        df_options:        [
            ["%Y%m%d",   "ггггммдд"]
            ["%y%m%d",   "ггммдд"]
            ["%d%m%y",   "ддммгг"]
            ["%d.%m.%Y", "дд.мм.гггг"]
            ["%d/%m/%Y", "дд/мм/гггг"]
            ["%m/%d/%Y", "мм/дд/гггг"]
            ["%d.%m.%y", "дд.мм.гг"]
            ["%d/%m/%y", "дд/мм/гг"]
            ["%m/%d/%y", "мм/дд/гг"]
        ]
        tf_label:          "Формат времени:"
        tf_options:        [
            ["%H%M%S",   "ччммсс"]
            ["%H%M",     "ччмм"]
            ["%H:%M:%S", "чч:мм:сс"]
            ["%H:%M",    "чч:мм"]
        ]
        csv_download:      "CSV"
        xml_download:      "XML"
        choose_date:       "Выбрать дату"
        placeholder:       "Весь период"
        date_format_label: "ДД.ММ.ГГГГ"
    en:
        datepicker_locale: "en-GB"
        csv_options_link:  "&or;"
        csv_options_title: "CSV rendering options"
        dp_label:          "Decimals separator:"
        dp_options:        [
            [".", "(.) point"]
            [",", "(,) comma"]
        ]
        dl_label:          "Fields delimiter:"
        dl_options:        [
            [";", "(;) semicolon"]
            [",", "(,) comma"]
        ]
        df_label:          "Date format:"
        df_options:        [
            ["%Y%m%d", "yyyymmdd"]
            ["%y%m%d", "yymmdd"]
            ["%d%m%y", "ddmmyy"]
            ["%d.%m.%Y", "dd.mm.yyyy"]
            ["%d/%m/%Y", "dd/mm/yyyy"]
            ["%m/%d/%Y", "mm/dd/yyyy"]
            ["%d.%m.%y", "dd.mm.yy"]
            ["%d/%m/%y", "dd/mm/yy"]
            ["%m/%d/%y", "mm/dd/yy"]
        ]
        tf_label:          "Time format:"
        tf_options:        [
            ["%H%M%S",   "hhmmss"]
            ["%H%M",     "hhmm"]
            ["%H:%M:%S", "hh:mm:ss"]
            ["%H:%M",    "hh:mm"]
        ]
        csv_download:      "CSV"
        xml_download:      "XML"
        choose_date:       "Choose date"
        placeholder:       "Entire period"
        date_format_label: "DD.MM.YYYY"

l10n = localization[mx.locale()]

$.datepicker.regional['ru'] =
    closeText:          'Закрыть'
    prevText:           '&#x3C;'
    nextText:           '&#x3E;'
    currentText:        'Сегодня'
    monthNames:         ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь']
    monthNamesShort:    ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек']
    dayNames:           ['воскресенье','понедельник','вторник','среда','четверг','пятница','суббота']
    dayNamesShort:      ['вск','пнд','втр','срд','чтв','птн','сбт']
    dayNamesMin:        ['Вс','Пн','Вт','Ср','Чт','Пт','Сб']
    weekHeader:         'Нед'
    dateFormat:         'dd.mm.yy'
    firstDay:           1
    isRTL:              false
    showMonthAfterYear: false
    yearSuffix:         ''

$.datepicker.regional['en-GB'] =
    prevText:           '&#x3C;'
    nextText:           '&#x3E;'

$.datepicker.setDefaults $.datepicker.regional[l10n.datepicker_locale]


check_date = (date) ->
    if typeof date is "string"
        date = date.split(".")
        if date.length is 3
            day  = date[0] ; month = date[1] ; year = date[2]
            if day and month and year
                cy  = (new Date).getFullYear()
                day = parseInt(day) ; month = parseInt(month) ; year = parseInt(year)
                day   = if day   < 10   then "0#{day}"   else if day   > 31 then "31"    else "#{day}"
                month = if month < 10   then "0#{month}" else if month > 12 then "12"    else "#{month}"
                year  = 2000 + year if year < 100
                year  = if year  < 2000 then "2000"      else if year  > cy then "#{cy}" else "#{year}"
                return "#{year}-#{month}-#{day}"
    undefined


render_tempate = (el) ->
    el = $(el) ; return unless el.length > 0
    el.html """
        <div class="datepicker">
            <input class="datepicker-input" />
            <label class="datepicker-label">#{l10n.date_format_label}</label>
        </div>
        <a class="date-period-reset">#{l10n.placeholder}</a>
        <ul class="download-links">
            <li class="csv">
                <a href="#" class="download">#{l10n.csv_download}</a><a class="options">#{l10n.csv_options_link}</a>
            </li>
            <li class="xml">
                <a href="#" class="download">#{l10n.xml_download}</a>
            </li>
        </ul>
        <div class="clear"></div>
        <div id="csv-options">
            <fieldset>
                <legend>#{l10n.csv_options_title}</legend>
                <p>
                    <label for="csv-dp">#{l10n.dp_label}</label>
                    <select id="csv-dp">
                    </select>
                </p>
                <p>
                    <label for="csv-dl">#{l10n.dl_label}</label>
                    <select id="csv-dl">
                    </select>
                </p>
                <p>
                    <label for="csv-df">#{l10n.df_label}</label>
                    <select id="csv-df">
                    </select>
                </p>
                <p>
                    <label for="csv-tf">#{l10n.tf_label}</label>
                    <select id="csv-tf">
                    </select>
                </p>
            </fieldset>
        </div>
    """

populate_options = (el, options) ->
    for option, index in options
        opt = $("<option>").val(option[0]).html(option[1])
        opt.selected = true if index is 0
        el.append(opt)


widget = (element, options = {}) ->
    element = $(element) ; return unless element.length > 0
    element.addClass("mx-widget-ranks-archive")

    iss_dp        = l10n.dp_options[0][0]
    iss_dl        = l10n.dl_options[0][0]
    iss_df        = l10n.df_options[0][0]
    iss_tf        = l10n.tf_options[0][0]

    render_tempate(element)

    # select controlable elements from template
    controls =
        datepicker        : $ ".datepicker .datepicker-input",  element
        csv_options       : $ "#csv-options",                   element
        csv_options_link  : $ ".download-links .csv .options",  element
        reset_period_link : $ ".date-period-reset",             element
        link_to_csv       : $ ".download-links .csv .download", element
        link_to_xml       : $ ".download-links .xml .download", element
        select_dp         : $ "#csv-dp",                        @csv_options
        select_dl         : $ "#csv-dl",                        @csv_options
        select_df         : $ "#csv-df",                        @csv_options
        select_tf         : $ "#csv-tf",                        @csv_options

    populate_options(controls.select_dp, l10n.dp_options)
    populate_options(controls.select_dl, l10n.dl_options)
    populate_options(controls.select_df, l10n.df_options)
    populate_options(controls.select_tf, l10n.tf_options)

    controls.datepicker.datepicker
        onSelect:          (selected) ->
            controls.reset_period_link.addClass("active")
            update_links()
        dateFormat:        "dd.mm.yy"
        showOn:            "button"
        buttonImageOnly:   true
        buttonText:        l10n.choose_date
        maxDate:           "-1D"
        beforeShow: (input, inst) ->
            calendar = inst.dpDiv
            calendar.css({marginLeft: input.offsetWidth + 'px'})

    controls.csv_options.hide()

    start_events = (ctrls) ->
        ctrls.datepicker.keyup () ->
            ctrls.reset_period_link.addClass("active") unless check_date(ctrls.datepicker.val())
            update_links()

        ctrls.datepicker.focus () ->
            el    = $(this)
            value = el.val()
            el.val("") if value is l10n.placeholder

        ctrls.datepicker.blur () ->
            el    = $(this)
            value = el.val()
            unless check_date(value)
                el.val(l10n.placeholder)
                ctrls.reset_period_link.removeClass("active")

        ctrls.reset_period_link.click () ->
            ctrls.datepicker.datepicker("setDate", undefined)
            ctrls.datepicker.val(l10n.placeholder)
            update_links()
            $(this).removeClass("active")

        ctrls.csv_options_link.click () ->
            unless $(this).hasClass("disabled")
                $(this).toggleClass("active")
                ctrls.csv_options.toggle()

        ctrls.select_dp.change () ->
            iss_dp = $(this).find(":selected").val()
            update_links()

        ctrls.select_dl.change () ->
            iss_dl = $(this).find(":selected").val()
            update_links()


    update_links = () ->
        date   = check_date(controls.datepicker.attr("value"))
        params = [
            "iss.dp=#{iss_dp}"
            "iss.delimiter=#{iss_dl}"
            "iss.df=#{iss_df}"
            "iss.tf=#{iss_tf}"
        ].join("&")
        if date
            controls.csv_options_link.removeClass("disabled")
            controls.link_to_csv.attr("href", [link_given_date, ".csv", "?date=#{date}&", params, "&#{link_params}"].join("")).html(l10n.csv_download)
            controls.link_to_xml.attr("href", [link_given_date, ".xml", "?date=#{date}&", "&#{link_params}"].join("")).html(l10n.xml_download)
        else
            controls.csv_options.hide()
            controls.csv_options_link.removeClass("active").addClass("disabled")
            controls.link_to_csv.attr("href", [link_entire_period, ".csv"].join("")).html(l10n.csv_download)
            controls.link_to_xml.attr("href", [link_entire_period, ".xml"].join("")).html(l10n.xml_download)

    start_events(controls) ; controls.reset_period_link.trigger("click") ; update_links()

_.extend scope,
    ranks_archive: widget