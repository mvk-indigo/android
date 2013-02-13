var app = {
  initialize: function() {
    this.bind();
  },
  bind: function() {
    $(document).on("deviceready", this.deviceready);
  },
  deviceready: function() {
    $(".app .scan").on("touchstart click", function() {
      window.plugins.barcodeScanner.scan(function(result) {
        $(".app .scan").hide();
        $(".app .results")
          .show()
          .find(".text")
          .text(result.text)
          .end()
          .find(".format")
          .text(result.format);

      }, function(error) {
          alert("Scanning failed: " + error);
      });
    });
  }
};
