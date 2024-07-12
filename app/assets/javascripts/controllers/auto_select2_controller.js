import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-select2"
export default class extends Controller {
  connect() {
    var self = this,
        el = self.element
    $(el).select2({
      dropdownParent: $(el).parent(),
      minimumInputLength: el.dataset.minimumInputLength || 0,
      placeholder: el.dataset.placeholder || 'Select...'
    })
  }
}
