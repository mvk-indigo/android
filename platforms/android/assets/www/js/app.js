// Generated by CoffeeScript 1.3.3
(function() {
  var $cached, ENDPOINT, ENVIRONMENT_MAX_INDEX, HEALTH_MAX_INDEX, MOCK_PRODUCT, SCREEN_WIDTH, cacheSelectors, calculateEnvironmentPercent, calculateHealthPercent, deviceready, displayError, displayProduct, displaySearchResults, fetchResult, filterProducts, gotoScreen, listEnvironmentRisks, listHealthRisks, listRisks, scan, screenIndex, search, serverWakeUp;

  ENDPOINT = "http://fierce-harbor-8745.herokuapp.com/product";

  SCREEN_WIDTH = 320;

  ENVIRONMENT_MAX_INDEX = 8;

  HEALTH_MAX_INDEX = 8;

  MOCK_PRODUCT = {
    "R": "37, 38, 41",
    "_id": "",
    "index": "64.5",
    "product_name": "Kakelfog Lorem Ipsum Dolor",
    "desc": "Cementbaserat fogbruk f\u00f6r fogning av keramiska plattor p\u00e5 v\u00e4gg och golv i v\u00e5ta och torra utrymmen. \u00c4ven f\u00f6r utomhusbruk.",
    "content": [
      {
        "ingredient_name": "Cement",
        "percentage": "30-50"
      }, {
        "ingredient_name": "Kalciumkarbonat",
        "percentage": "30-60"
      }
    ],
    "manufacturer": "Kiilto",
    "image_link": "https://dl.dropboxusercontent.com/u/24952358/MVK-bilder/Ny%20mapp/kakelfog.jpg",
    "ean-code": "6411513523100"
  };

  $cached = {};

  screenIndex = 1;

  cacheSelectors = function() {
    return $cached = {
      body: $("body"),
      app: $(".app"),
      home: {
        $: $("#home"),
        scan: $(".scan"),
        search: $(".search")
      },
      product: {
        $: $("#product")
      },
      searchResults: {
        $: $("#search-results")
      },
      templates: {
        product: $("#product-template"),
        searchResults: $("#search-results-template")
      }
    };
  };

  deviceready = function() {
    serverWakeUp();
    $cached.home.scan.on("click", function() {
      $cached.home.scan.addClass("touch");
      return setTimeout(scan, 100);
    });
    $cached.home.search.on("click", function() {
      $cached.home.search.addClass("touch");
      return setTimeout(search, 100);
    });
    return $(document).on("backbutton", function(e) {
      var index;
      e.preventDefault();
      if (screenIndex === 1) {
        return navigator.app.exitApp();
      } else {
        index = screenIndex - 1;
        return gotoScreen({
          index: index,
          backward: true
        });
      }
    });
  };

  scan = function() {
    return window.plugins.barcodeScanner.scan((function(_arg) {
      var cancelled, format, text;
      cancelled = _arg.cancelled, text = _arg.text, format = _arg.format;
      $cached.home.scan.removeClass("touch");
      if (cancelled) {
        return;
      }
      return fetchResult({
        code: text,
        success: (function(result) {
          return displayProduct(result[0]);
        }),
        error: displayError
      });
    }), function(error) {
      return alert("Skanning misslyckades: " + error, function() {});
    });
  };

  search = function() {
    var searchWord;
    searchWord = prompt("Ange sökord");
    $cached.home.search.removeClass("touch");
    if (!searchWord) {
      return;
    }
    return fetchResult({
      name: searchWord,
      success: (function(result) {
        if (result.length === 1) {
          return displayProduct(result[0]);
        }
        return displaySearchResults(result);
      }),
      error: displayError
    });
  };

  fetchResult = function(_arg) {
    var code, error, errorCallback, name, params, success;
    name = _arg.name, code = _arg.code, error = _arg.error, success = _arg.success;
    params = {
      name: name,
      ean_code: code
    };
    errorCallback = function() {
      return typeof error === "function" ? error("Produkten hittades inte") : void 0;
    };
    return $.getJSON(ENDPOINT, params).success(function(data) {
      var filtered;
      filtered = filterProducts(data.result);
      if (!filtered.length) {
        return errorCallback();
      }
      return typeof success === "function" ? success(filtered) : void 0;
    }).error(errorCallback);
  };

  displaySearchResults = function(products) {
    var template;
    if (!products.length) {
      return;
    }
    gotoScreen({
      id: "search-results"
    });
    template = _.template($cached.templates.searchResults.html());
    $cached.searchResults.$.html(template({
      products: products
    }));
    $cached.searchResults.$.off("click ");
    return $cached.searchResults.$.on("click", "li", function(e) {
      var $this;
      $this = $(this);
      $this.addClass("touch");
      _.delay((function() {
        return $this.removeClass("touch");
      }), 500);
      return displayProduct(products[$this.data("index")]);
    });
  };

  displayProduct = function(product) {
    var environmentPercent, healthPercent, template;
    if (!product) {
      return;
    }
    gotoScreen({
      id: "product"
    });
    template = _.template($cached.templates.product.html());
    environmentPercent = calculateEnvironmentPercent(product);
    healthPercent = calculateHealthPercent(product);
    $cached.product.$.html(template({
      product: product,
      environmentPercent: environmentPercent,
      healthPercent: healthPercent,
      risks: listRisks(product.R, _.defaults({}, window.RISK_PHRASES.ENVIRONMENT, window.RISK_PHRASES.HEALTH))
    }));
    return _.delay(function() {
      $(".environment .fill").css("width", environmentPercent + "%");
      return $(".health .fill").css("width", healthPercent + "%");
    }, 1000);
  };

  displayError = function(error) {
    return alert(error);
  };

  gotoScreen = function(_arg) {
    var $screen, backward, id, index;
    id = _arg.id, index = _arg.index, backward = _arg.backward;
    if (id) {
      $screen = $("#" + id);
    } else if (index) {
      $screen = $("section[data-index=" + index + "]");
    } else {
      return;
    }
    $screen.css("display", "inline-block");
    screenIndex += backward ? -1 : 1;
    return $cached.app.transition({
      x: -(screenIndex - 1) * SCREEN_WIDTH
    }, 500, function() {
      if (screenIndex === 1) {
        return $cached.searchResults.$.hide();
      }
    });
  };

  serverWakeUp = function() {
    return $.get(ENDPOINT);
  };

  calculateEnvironmentPercent = function(product) {
    return (listEnvironmentRisks(product.R).length / ENVIRONMENT_MAX_INDEX) * 100;
  };

  calculateHealthPercent = function(product) {
    return (listHealthRisks(product.R).length / HEALTH_MAX_INDEX) * 100;
  };

  listEnvironmentRisks = function(rString) {
    return listRisks(rString, window.RISK_PHRASES.ENVIRONMENT);
  };

  listHealthRisks = function(rString) {
    return listRisks(rString, window.RISK_PHRASES.HEALTH);
  };

  listRisks = function(rString, phrases) {
    var item, risk, risks, _i, _len, _ref;
    if (!rString) {
      return [];
    }
    risks = [];
    _ref = rString.split(" ");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      risk = phrases[item.replace(",", "")];
      if (risk) {
        risks.push(risk);
      }
    }
    return risks;
  };

  filterProducts = function(products) {
    return _.filter(products, function(item) {
      return item.R;
    });
  };

  window.app = {
    initialize: function() {
      $(document).on("deviceready", deviceready);
      cacheSelectors();
      return FastClick.attach(document.body);
    }
  };

}).call(this);
