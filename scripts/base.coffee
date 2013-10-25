
do ->
  if window.moment
    window.moment.lang 'zh-cn'

  window.$tmpl = (name, data = {}) ->
    data.linkArticle = -> "article.html?id=#{@id}"

    $tmplContainer = $ "##{name}[type='text/template']"
    $tmplDataset = $tmplContainer.data()
    resultHtml = templayed($tmplContainer.html()) data
    $result = $('<div>').html(resultHtml).children()

    action = do ->
      for name, value of $tmplDataset when /^tmpl[A-Z]/.test name
        return {
          method: name.replace(/^tmpl/, '').toLowerCase()
          selector: value
        }

    if action
      $target = $ action.selector
      $target[action.method]? $result
      console.log '$target', $target, 'method', action.method

    $result


do ->
  $.fn.spin = (options) ->
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

do ->
  appid = 793

  window.reqconf =
    urlRoot: "/api/apps/#{appid}"
    appid: appid
    poilcyCategory: (id) ->
      id in [105, 106, 107, 108]
    settledEnterpriseCategory: (id) ->
      if id? then id is 109 else 109
    newsCategory: (id) ->
      return false if reqconf.poilcyCategory id
      return false if reqconf.settledEnterpriseCategory id
      true

do ->
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

