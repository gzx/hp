
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
    resultHtml = templayed($tmplElem.html()) data
    $contents = $('<div>').html(resultHtml).contents()

    action = do ->
      for dataname, datavalue of $tmplElemDataset when /^tmpl[A-Z]/.test dataname
        return {
          method: dataname.replace(/^tmpl/, '').toLowerCase()
          selector: datavalue
        }

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

do -> # config spin [[[
  $.fn.spin = (options) ->
    if options isnt false
      options = $.extend {
        color: '#555'
        width: 4
      }, options

    @each (index, elem) =>
      $elem = @eq index
      spin = $elem.data('spin') or new Spinner options
      if options is false
        spin.stop()
        $elem.removeData 'spin'
      else
        $elem.data 'spin', spin
        spin.spin elem
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
      validateIds = [108, 105, 106, 107]
      return validateIds unless categories

      result = []

      for category in categories
        index = validateIds.indexOf category.id
        continue if index is -1
        result[index] = category

      result

    settledEnterpriseCategory: (id) ->
      if id? then id is 109 else 109

    newsCategory: (categories) ->
      result = for category in categories
        continue if reqconf.poilcyCategory([category]).length
        continue if reqconf.settledEnterpriseCategory category.id
        continue if category.id in [126, 127, 128]
        category
      for category, index in result
        continue if category.id isnt 104
        result.splice index, 1
        result.push category

      result
# ]]]

