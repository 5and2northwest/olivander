import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="turbo-flash"
export default class extends Controller {
  connect() {
    var style = this.element.dataset.flashStyle || 'info';
    flashToast([[style, this.element.innerHTML]]);
    this.element.parentNode.removeChild(this.element);
  }
}
