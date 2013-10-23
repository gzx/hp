
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

