(function() {
  toastr.options = {
    closeButton: true,
    debug: false,
    progressBar: true,
    positionClass: "toast-top-right",
    showDuration: 300,
    hideDuration: 1000,
    timeOut: 5000,
    extendedTimeOut: 1000,
    showEasing: "swing",
    hideEasing: "linear",
    showMethod: "fadeIn",
    hideMethod: "fadeOut"
  };

  window.flashToast = function(flashes) {
    var flash, i, len, results, show;
    show = function(flash) {
      var e, msg, options, opts, type, types;
      types = {
        notice: 'success',
        success: 'success',
        alert: 'error',
        error: 'error',
        warning: 'warning',
        info: 'info'
      };
      options = {
        notice: {},
        alert: {
          "timeOut": "0",
          "extendedTimeOut": "0"
        },
        warning: {
          "timeOut": "0",
          "extendedTimeOut": "0"
        },
        info: {}
      };
      type = types[flash[0]];
      opts = options[flash[0]];
      msg = flash[1];
      try {
        if (msg) {
          return toastr[type](msg, '', opts);
        }
      } catch (error) {
        e = error;
        if (msg) {
          return toastr.info(msg, '', opts);
        }
      }
    };
    results = [];
    for (i = 0, len = flashes.length; i < len; i++) {
      flash = flashes[i];
      results.push(show(flash));
    }
    return results;
  };

}).call(this);