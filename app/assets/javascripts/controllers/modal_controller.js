import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    $(this.element).modal('show');
  }

  disconnect() {
    $(this.element).modal('hide');
  }
}
