// Generated by CoffeeScript 1.3.3
(function() {

  window.app = {
    initialize: function() {
      return this.bind();
    },
    bind: function() {
      return $(document).on("deviceready", this.deviceready);
    },
    deviceready: function() {
      return window.plugins.barcodeScanner.scan((function(result) {
        $(".app .scan").hide();
        return $(".app .results").show().find(".text").text(result.text).end().find(".format").text(result.format);
      }), function(error) {
        return alert("Scanning failed: " + error);
      });
    }
  };

}).call(this);