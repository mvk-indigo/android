SCREEN_WIDTH = 320
MOCK_PRODUCT =
  name: "Elegant Aqua Lackfärg Matt 10"
  description: "Lackfärg av högsta kvalitet för alla slags möbler
 och snickerier inomhus. Färgen är lätt att måla med och ger vacker yta."
  image: "http://www.bauhaus.se/media/catalog/product/cache/1/image/
265x/9df78eab33525d08d6e5fb8d27136e95/5/3/5366810S.jpg"
  url: "http://www.bauhaus.se/elegant-aqua-lackfarg-matt-10.html"

$cached = {}
screenIndex = 1

window.testProduct = ->
  cacheSelectors()
  displayProduct MOCK_PRODUCT

cacheSelectors = ->
  $cached =
    body: $ "body"
    app: $ ".app"

    home:
      $: $ "#home"
      scan: $ ".scan"
      search: $ ".search"

    product:
      $: $ "#product"

    templates:
      product: $ "#product-template"

deviceready = ->
  cacheSelectors()

  $cached.home.scan.on "click", ->
    $cached.home.scan.addClass "touch"
    setTimeout scan, 100

  $cached.home.search.on "click", ->
    $cached.home.search.addClass "touch"
    setTimeout search, 100

  $(document).on "backbutton", (e) ->
    e.preventDefault()
    if screenIndex is 1
      navigator.app.exitApp()
    else
      gotoScreen(index: screenIndex - 1)

scan = ->
  window.plugins.barcodeScanner.scan (({cancelled, text, format}) ->
    $cached.home.scan.removeClass "touch"
    return if cancelled

    fetchProduct
      code: text
      success: displayProduct
      error: displayError

  ), (error) ->
    alert "Skanning misslyckades: " + error, ->

search = ->
  searchWord = prompt "Ange sökord"
  $cached.home.search.removeClass "touch"
  return unless searchWord

  fetchProduct
    name: searchWord
    success: displayProduct
    error: displayError

fetchProduct = ({name, code, error, success}) ->
  _success = true
  _.defer ->
    if _success
    then success? MOCK_PRODUCT
    else error? "Produkten hittades inte"

displayProduct = (product) ->
  gotoScreen id: "product"
  template = _.template $cached.templates.product.html()
  $cached.product.$.html template(product)

displayError = (error) ->
  alert error

gotoScreen = ({index, id}) ->
  if id
    $screen = $("##{id}")
    index = $screen.data("index")
  else if index
    $screen = $("section[data-index=#{index}]")

  screenIndex = index
  $cached.app.transition(
    x: -(index - 1) * SCREEN_WIDTH
  , 500)

window.app =
  initialize: -> $(document).on "deviceready", deviceready
