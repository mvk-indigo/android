$el = {}

deviceready = ->
  cacheSelectors()
  $el.body.show()

  $el.scan.on "touchstart", ->
    $el.scan.addClass "touch"
    setTimeout scan, 100

  $el.search.on "touchstart", ->
    $el.search.addClass "touch"
    setTimeout search, 100

scan = ->
  window.plugins.barcodeScanner.scan ((result) ->
    $el.scan.removeClass "touch"
    console.log JSON.stringify(result)
      # .text(result.text)
      # .text result.format

  ), (error) ->
    navigator.notification.alert "Scanning failed: " + error, ->

search = ->
  searchWord = prompt("Ange sökord")
  $el.search.removeClass "touch"
  console.log searchWord

cacheSelectors = ->
  $el =
    body: $ "body"
    scan: $ ".scan"
    search: $ ".search"

window.app =
  initialize: -> $(document).on "deviceready", deviceready
