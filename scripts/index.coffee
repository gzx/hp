

cleanHtml = (str) ->
  $.trim $('<div>').html(str).text()

fitImageFactory = (width = "", height = "") ->
  ->
    @image + "!#{width}x#{height}"

requester.get "/recommendations", (resp) ->

  data =
    list: resp
    cleanRecommendations: -> cleanHtml @target.context.content
    fitImage: fitImageFactory 520, 355

  recommendationListHtml = $tmpl 'recommendationList', data
  $(".recommenations .carousel-inner")
    .html(recommendationListHtml)
    .find(".item").first().addClass "active"

requester.get "/articles", {count: 4}, (resp) ->

  data =
    list: resp
    cleanContent: ->
      flatContent = cleanHtml @content
      return flatContent if flatContent.length < 27
      flatContent.substr(0, 27) + "..."

  articleListHtml = $tmpl 'articleList', data
  $(".news ul").html articleListHtml

