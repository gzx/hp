
do -> # shim console [[[
  return if window.console?
  console = window.console = {}
  methods = """
    log
    dir
    info
    warn
    error
    debug
    trace
    count
    assert
    dirxml
    exception
    markTimeline
    groupCollapsed
    group
    groupEnd
    profile
    profileEnd
    time
    timeEnd
  """.split /\s/

  for method in methods
    console[method] = ->
# ]]]

do -> # config app [[[
  appid = 793

  window.reqconf =
    urlRoot: "/api/apps/#{appid}"

    appid: appid

    imageProcesser: (url, width, height) ->
      # 防止出现 base64 的图片
      return url unless /^http(s)?:/.test url
      # 防止出现其他站点的图片
      return url unless /images\.(appatom|gezbox)\.com/.test url
      "#{url}!#{width or ''}x#{height or ''}"

    poilcyCategory: (categories) ->
      for category in categories when category.name is '服务与政策'
        return category.sub_categories
      []

    newsCategory: (categories) ->
      for category in categories when category.name is '新闻中心'
        return category.sub_categories
      []
# ]]]

do -> # generatePagination [[[
    window.generatePagination = (baseUrl, maxPage, currentPage) ->
      maxPage or= 1
      prevPage = currentPage - 1
      nextPage = currentPage + 1
      pagination = pages: []

      generatePageData = (num) ->
        num: num, url: "#{baseUrl}&page=#{num}", active: currentPage is num

      pagination.prevPage = generatePageData(prevPage) if prevPage >= 1
      pagination.nextPage = generatePageData(nextPage) if nextPage <= maxPage

      # 1 2 3 4 5 6 7 8 9
      #
      # (1) 2 3 4 ... 9 10
      # 1 (2) 3 4 ... 9 10
      # 1 2 (3) 4 ... 9 10
      #
      # 1 2 3 (4) 5 ... 9 10
      #
      # 1 2 ... 4 (5) 6 ... 9 10
      # 1 2 ... 5 (6) 7 ... 9 10
      #
      # 1 2 ... 6 (7) 8 9 10
      #
      # 1 2 ... 7 (8) 9 10
      # 1 2 ... 7 8 (9) 10
      # 1 2 ... 7 8 9 (10)
      if maxPage < 10
        pagination.pages.push(generatePageData num) for num in [1..maxPage]

      else if 1 <= currentPage < 4
        pagination.pages.push(generatePageData num) for num in [1..4]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [maxPage - 1, maxPage]

      else if currentPage is 4
        pagination.pages.push(generatePageData num) for num in [1..5]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [maxPage - 1, maxPage]

      else if currentPage is maxPage - 3
        pagination.pages.push(generatePageData num) for num in [1, 2]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [maxPage - 4..maxPage]

      else if maxPage - 3 < currentPage <= maxPage
        pagination.pages.push(generatePageData num) for num in [1, 2]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [maxPage - 3..maxPage]

      else
        pagination.pages.push(generatePageData num) for num in [1, 2]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [currentPage - 1, currentPage, currentPage + 1]
        pagination.pages.push ellipsis: true
        pagination.pages.push(generatePageData num) for num in [maxPage - 1, maxPage]

      pagination
# ]]]

do -> # $tmpl [[[
  window.$tmpl = (name, data = {}) ->
    $tmplElem = $ "##{name}[type='text/template']"
    throw Error 'template element not exist' unless $tmplElem.length

    $tmplElemDataset = $tmplElem.data()
    resultHtml = Handlebars.compile($tmplElem.html()) data

    $container = $('<div>').html resultHtml
    if bowser.msie and bowser.version < 8
      $container.find('[data-tmpl-unescape]').each (index, elem) ->
        $elem = $ elem
        unescapedHTML = $('<div>').html($elem.text()).html()
        $elem.empty().html unescapedHTML
    $contents = $container.contents()

    action = do ->
      for dataname, datavalue of $tmplElemDataset when /^tmpl[A-Z]/.test dataname
        method = dataname.replace(/^tmpl/, '').toLowerCase()
        continue if method is 'unescape'
        return method: method, selector: datavalue

    if action
      $target = $ action.selector
      $target[action.method]? $contents
      console.log 'render template', name, {
        '$target': $target
        'template': $tmplElem.html()
        'data': data
        'method': action.method
      }

    $contents
# ]]]

do -> # requester [[[
  requester = (config) ->
    config = $.extend true, {}, config
    config.url = reqconf.urlRoot + config.url
    $.ajax config

  for method in ['get', 'post']
    do (method) ->
      requester[method] = (url, data, callback) ->
        if $.isFunction data
          callback = data
          data = undefined

        config =
          url: url
          type: method
          data: data
          success: callback
          cache: false

        if method is 'post'
          config.contentType = 'application/json'

        requester config

  window.requester = requester
# ]]]

do -> # getParam [[[
  window.getParam = (url, key) ->
    re = ///\??#{key}=([^&]*)///g
    result = re.exec url
    if result? and result.length > 1
      decodeURIComponent result[1]
    else
      ""
# ]]]

do -> # activeMenuItem [[[
  window.activeMenuItem = (type, id) ->
    $items = $ '.menu-list li > a'

    $items.filter (index) ->
      $item = $items.eq index
      matchs = $item.attr('href').match /\/?([^\/]+)$/
      return false unless matchs and matchs[1]
      matchs[1] is "#{type}.html?id=#{id}"
    .addClass 'active'
# ]]]

do -> # config moment [[[
  if window.moment
    window.moment.lang 'zh-cn'
# ]]]

do -> # config $tmpl [[[
  $tmpl = window.$tmpl
  window.$tmpl = (name, data = {}) ->
    data.linkArticle = -> window.$tmpl.linkArticle @id
    data.linkPage = -> window.$tmpl.linkPage @id
    $tmpl name, data

  window.$tmpl.linkArticle = (id) -> "article.html?id=#{id}"
  window.$tmpl.linkPage = (id) -> "page.html?id=#{id}"
# ]]]

do ->
  return unless bowser.c
  $(".alert").detach().prependTo('body')
  $(".alert").removeClass "hide"
  $("body").on 'click', '.close', ->
    $(".alert").remove()

do -> # config spin [[[
  if bowser.msie and bowser.version < 8
    $.fn.spin = -> this
    return

  spin = $.fn.spin
  wrapper = (options, color) ->
    if options isnt false
      color or= '#555'
      options or= {}
      options.width or= 4
    spin.call this, options, color
  $.fn.spin = wrapper
  wrapper.presets = spin.presets
# ]]]

do -> # add method momentFromISO [[[
  window.momentFromISO = (time) ->
    moment(time, 'YYYY-MM-DDTHH:mm:ssZZ')
# ]]]



