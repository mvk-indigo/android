ENDPOINT = "http://fierce-harbor-8745.herokuapp.com/product"
SCREEN_WIDTH = 320
MAX_INDEX = 80
MIN_INDEX = 5

MOCK_PRODUCT = {
  "R": "37, 38, 41",
  "_id": "",
  "index": "64.5",
  "product_name": "Kakelfog",
  "desc": "Cementbaserat fogbruk f\u00f6r fogning av keramiska plattor p\u00e5 v\u00e4gg och golv i v\u00e5ta och torra utrymmen. \u00c4ven f\u00f6r utomhusbruk.",
  "content": [{
    "ingredient_name": "Cement",
    "percentage": "30-50"
  }, {
    "ingredient_name": "Kalciumkarbonat",
    "percentage": "30-60"
  }],
  "manufacturer": "Kiilto",
  "image_link": "https://dl.dropboxusercontent.com/u/24952358/MVK-bilder/Ny%20mapp/kakelfog.jpg",
  "ean-code": "6411513523100"
}

$cached = {}
screenIndex = 1

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
  serverWakeUp()

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
    fetchResult
      code: text
      success: ((result) -> displayProduct result[0])
      error: displayError

  ), (error) ->
    alert "Skanning misslyckades: " + error, ->

search = ->
  searchWord = prompt "Ange sökord"
  $cached.home.search.removeClass "touch"
  return unless searchWord

  fetchResult
    name: searchWord
    success: ((result) -> displayProduct result[0])
    error: displayError

fetchResult = ({name, code, error, success}) ->
  params = { name: name, ean_code: code }
  errorCallback = -> error? "Produkten hittades inte"
  $.getJSON(ENDPOINT, params)
    .success((data) ->
      return errorCallback() unless data.result.length
      success? data.result
    )
    .error(errorCallback)

displayProduct = (product) ->
  return unless product

  gotoScreen id: "product"
  template = _.template $cached.templates.product.html()

  environmentPercent = calculateEnvironmentPercent product.index

  $cached.product.$.html template(
    product: product
    environmentPercent: environmentPercent
    risks: listRisks product.R
  )

  _.delay(->
    $(".rating-container .fill").css("width", environmentPercent + "%")
  , 1000)


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

# Send a request to wake up the server
serverWakeUp = ->
  $.get ENDPOINT

calculateEnvironmentPercent = (index) ->
  100 - ((index - MIN_INDEX) / (MAX_INDEX - MIN_INDEX)) * 100

listRisks = (rString) ->
  return [] unless rString
  _(rString.split(", ")).map((item) -> RISK_PHRASES[item])

window.app =
  initialize: ->
    cacheSelectors()
    $(document).on "deviceready", deviceready
    # displayProduct MOCK_PRODUCT
