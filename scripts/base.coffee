
do ->
  if window.moment
    window.moment.lang 'zh-cn'

  window.tmpl = (name, data) ->
    templayed($("##{name}[type='text/template']").html()) data

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
  appid = 102

  window.reqconf =
    urlRoot: "/api/apps/#{appid}"
    appid: appid

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

