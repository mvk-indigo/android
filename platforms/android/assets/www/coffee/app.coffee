ENDPOINT = "http://fierce-harbor-8745.herokuapp.com/product"
SCREEN_WIDTH = 320

ENVIRONMENT_MAX_INDEX = 8
HEALTH_MAX_INDEX = 8

MOCK_PRODUCT = {
  "R": "37, 38, 41",
  "_id": "",
  "index": "64.5",
  "product_name": "Kakelfog Lorem Ipsum Dolor",
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

    searchResults:
      $: $ "#search-results"

    templates:
      product: $ "#product-template"
      searchResults: $ "#search-results-template"

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
      index = screenIndex - 1
      gotoScreen(index: index, backward: true)

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
    success: ((result) ->
      return displayProduct result[0] if result.length is 1
      displaySearchResults result
    )
    error: displayError

fetchResult = ({name, code, error, success}) ->
  params = { name: name, ean_code: code }
  errorCallback = -> error? "Produkten hittades inte"
  $.getJSON(ENDPOINT, params)
    .success((data) ->
      filtered = filterProducts data.result
      return errorCallback() unless filtered.length
      success? filtered
    )
    .error(errorCallback)

displaySearchResults = (products) ->
  return unless products.length

  gotoScreen id: "search-results"
  template = _.template $cached.templates.searchResults.html()

  $cached.searchResults.$.html template(
    products: products
  )

  $cached.searchResults.$.off "click "
  $cached.searchResults.$.on "click", "li", (e) ->
    $this = $ this
    $this.addClass "touch"
    _.delay (-> $this.removeClass "touch"), 500
    displayProduct products[$this.data "index"]

displayProduct = (product) ->
  return unless product

  gotoScreen id: "product"
  template = _.template $cached.templates.product.html()

  environmentPercent = calculateEnvironmentPercent product
  healthPercent = calculateHealthPercent product

  $cached.product.$.html template(
    product: product
    environmentPercent: environmentPercent
    healthPercent: healthPercent
    risks: listRisks(
      product.R,
      _.defaults {}, window.RISK_PHRASES.ENVIRONMENT, window.RISK_PHRASES.HEALTH
    )
  )

  _.delay(->
    $(".environment .fill").css("width", environmentPercent + "%")
    $(".health .fill").css("width", healthPercent + "%")
  , 1000)


displayError = (error) ->
  alert error

gotoScreen = ({id, index, backward}) ->
  if id
    $screen = $("##{id}")
  else if index
    $screen = $("section[data-index=#{index}]")
  else
    return

  $screen.css("display", "inline-block");
  screenIndex += if backward then -1 else 1

  $cached.app.transition(
    x: -(screenIndex - 1) * SCREEN_WIDTH
  , 500, ->
    $cached.searchResults.$.hide() if screenIndex is 1
  )

# Send a request to wake up the server
serverWakeUp = ->
  $.get ENDPOINT

calculateEnvironmentPercent = (product) ->
  (listEnvironmentRisks(product.R).length  / ENVIRONMENT_MAX_INDEX) * 100

calculateHealthPercent = (product) ->
  (listHealthRisks(product.R).length  / HEALTH_MAX_INDEX) * 100

listEnvironmentRisks = (rString) ->
  listRisks rString, window.RISK_PHRASES.ENVIRONMENT

listHealthRisks = (rString) ->
  listRisks rString, window.RISK_PHRASES.HEALTH

listRisks = (rString, phrases) ->
  return [] unless rString
  risks = []
  for item in rString.split(" ")
    risk = phrases[item.replace(",", "")]
    risks.push(risk) if risk

  risks


filterProducts = (products) ->
  _.filter(products, (item) -> return item.R )

window.app =
  initialize: ->
    $(document).on "deviceready", deviceready
    cacheSelectors()
    FastClick.attach(document.body)
    # displayProduct MOCK_PRODUCT
