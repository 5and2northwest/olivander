(function() {
  var destroySelect2s, logEvent;

  $.extend(true, $.fn.dataTable.Buttons.defaults, {
    dom: {
      button: {
        className: 'btn btn-outline-primary btn-sm'
      }
    }
  });

  $.extend(true, $.fn.dataTable.ext.classes, {
    sProcessing: "dataTables_processing card overlay-wrapper"
  });

  destroySelect2s = function() {
    $('.effective-datatables-filters').find('select').select2('destroy');
    return $('.dataTables_wrapper').each(function(_, o) {
      try {
        return $(o).find('.dataTables_length select.select2-hidden-accessible').addClass('no-select2').removeAttr('name').select2('destroy');
      } catch (error) {}
    });
  };

  logEvent = function(e) {
    return console.log(e);
  };

  $(document).ready(function(e) {
    return destroySelect2s();
  });

  // $(document).ready(function(e) {
  //   return $('.effective-datatables-filters input').click(function() {
  //     var $form, $table;
  //     $form = $(event.currentTarget).closest('.effective-datatables-filters');
  //     $table = $('#' + $form.attr('aria-controls'));
  //     return $table.DataTable().draw();
  //   });
  // });

}).call(this);
