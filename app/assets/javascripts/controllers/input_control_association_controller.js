import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input-control-association"
export default class extends Controller {
  connect() {
    var self = this,
        el = self.element;
    if (!$(el).hasClass("select2-hidden-accessible")) {
      $(el).select2({
        dropdownParent: $(el).parent(),
        ajax: {
          url: el.dataset.collectionPath,
          delay: 250,
          minimumInputLength: 2,
          dataType: 'json',
          processResults: function(data) {
            return { results: data.map(function(map) {
              return { id: map.id, text: map.text || map.name || map.description };
            }) };
          }
        }
      })
    }
  }
}
