window.app =
  initialize: ->
    @bind()

  bind: ->
    $(document).on "deviceready", @deviceready

  deviceready: ->

  scan: ->
    window.plugins.barcodeScanner.scan ((result) ->
      $(".app .scan").hide()
      $(".app .results")
        .show()
        .find(".text")
        .text(result.text)
        .end()
        .find(".format")
        .text result.format

    ), (error) ->
      alert "Scanning failed: " + error

