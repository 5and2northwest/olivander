//= require "chartkick"
//= require Chart.bundle
//= require "adminlte/plugins/jquery/jquery.min.js"
//= require "adminlte/plugins/jquery-ui/jquery-ui.min.js"
//= require "adminlte/plugins/bootstrap/js/bootstrap.bundle.min.js"
//= require "adminlte/plugins/bootstrap-colorpicker/js/bootstrap-colorpicker.min.js"
//= require "adminlte/plugins/bootstrap-switch/js/bootstrap-switch.min.js"
//= require "adminlte/plugins/sparklines/sparkline.js"
//= require "adminlte/plugins/jqvmap/jquery.vmap.min.js"
//= require "adminlte/plugins/jqvmap/maps/jquery.vmap.usa.js"
//= require "adminlte/plugins/jquery-knob/jquery.knob.min.js"
//= require "adminlte/plugins/moment/moment.min.js"
//= require "adminlte/plugins/daterangepicker/daterangepicker.js"
//= require "adminlte/plugins/tempusdominus-bootstrap-4/js/tempusdominus-bootstrap-4.min.js"
//= require "adminlte/plugins/summernote/summernote-bs4.min.js"
//= require "adminlte/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"
//= require "adminlte/plugins/sweetalert2/sweetalert2.all.min.js"
//= require "adminlte/plugins/select2/js/select2.full.min.js"
//= require "adminlte/plugins/toastr/toastr.min.js"
//= require "adminlte/plugins/ekko-lightbox/ekko-lightbox.min.js"
//= require "adminlte/plugins/filterizr/jquery.filterizr.min.js"
//= require "adminlte/select2_defaults"
//= require "adminlte/dist/js/adminlte.js"
//= require 'olivander/flash_toast'
//= require "effective_datatables"
//= require "adminlte/datatable.fix.js"

$(document).ready(function(e) {
  var popperTexts = document.querySelectorAll('[data-popper-text]')
  popperTexts.forEach(function(el, idx) {
    var label = document.querySelector(`[for='${el.id}']`)
    label.innerHTML = label.innerHTML + `&nbsp;`
    var helpCircle = document.createElement('i')
    helpCircle.classList.add('fa', 'fa-question-circle', 'text-primary')
    helpCircle.addEventListener('click', function(evt) {
      Swal.fire(el.dataset.popperText)
    })
    label.appendChild(helpCircle)
  })
})