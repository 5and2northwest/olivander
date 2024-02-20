import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lightbox-image"
export default class extends Controller {
  connect() {
  }

  click(event) {
    event.preventDefault();
    $(event.target.parentElement).ekkoLightbox({
      alwaysShowClose: true
    });
  }
}
