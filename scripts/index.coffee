
$("#carousel-generic").carousel 'cycle'

cleanHtml = (str) ->
  cleanText = $.trim $('<div>').html(str).text()
  return cleanText if cleanText.length < 100
  cleanText.substr(0, 95) + "..."

fitImageFactory = (width = "", height = "") ->
  ->
    @image + "!#{width}x#{height}"

$('.header').click ->
  $.scrollTo '.body', 500, margin: true

requester.get "/recommendations", type: "article_banner", (resp) ->

  data =
    list: resp
    cleanRecommendations: -> cleanHtml @target.context.content
    fitImage: fitImageFactory 520, 355
    makeLink: ->
      switch @target.type
        when "article" then $tmpl.linkArticle @target.id
        when "page" then $tmpl.linkPage @target.id
        when "url" then @target.id
        else "javascript:"

  recommendationListHtml = $tmpl 'recommendationList', data
  $(".recommenations .carousel-inner")
    .html(recommendationListHtml)
    .find(".item").first().addClass "active"

requester.get "/articles", {count: 15}, (resp) ->
  result = []
  for article in resp
    if reqconf.newsCategory article.category.id
      result.push article

  result = result.slice 0, 4

  data =
    list: result
    cleanContent: ->
      flatContent = cleanHtml @content
      return flatContent if flatContent.length < 27
      flatContent.substr(0, 27) + "..."
    image: ->
      image = $('<div>').html(@content).find('img').first().attr 'src'
      unless image
        random = Math.ceil Math.random()*10
        return "./images/random/#{random}.jpg"

      if /http:/.test image
        "#{image}!70x70"
      else
        image

  articleListHtml = $tmpl 'articleList', data
  $(".news ul").html articleListHtml

