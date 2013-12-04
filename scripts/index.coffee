
$("#carousel-generic").carousel 'cycle'

cleanHtml = (str) ->
  cleanText = $.trim $('<div>').html(str).text()
  return cleanText if cleanText.length < 100
  cleanText.substr(0, 95) + "..."

$('.header').click ->
  $.scrollTo '.body', 500, margin: true

requester.get "/recommendations", type: "article_banner", (resp) ->

  data =
    list: resp
    cleanRecommendations: -> cleanHtml @target.context.content
    fitImage: -> reqconf.imageProcesser @image, 520, 355
    makeLink: ->
      switch @target.type
        when "article" then $tmpl.linkArticle @target.id
        when "page" then $tmpl.linkPage @target.id
        when "url" then @target.id
        else "javascript:;"

  recommendationListHtml = $tmpl 'recommendationList', data
  $(".recommenations .carousel-inner")
    .html(recommendationListHtml)
    .find(".item").first().addClass "active"

requester.get('/articles/categories').done (serverCategories) ->
  newsCategory = do ->
    for category in serverCategories
      return category if category.name is '新闻中心'

  requester.get "/articles", {count: 4, category: newsCategory.id}, (resp) ->
    data =
      list: resp
      cleanContent: ->
        flatContent = cleanHtml @content
        return flatContent if flatContent.length < 27
        flatContent.substr(0, 27) + "..."
      image: ->
        image = @images?[0]?.url or $('<div>').html(@content).find('img').first().attr 'src'
        unless image
          random = Math.ceil Math.random()*10
          image = "./images/random/#{random}.jpg"

        reqconf.imageProcesser image, 140, 140

    articleListHtml = $tmpl 'articleList', data
    $(".news ul").html articleListHtml

