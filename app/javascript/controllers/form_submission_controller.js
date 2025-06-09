import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-submission"
export default class extends Controller {
  connect() {
  }

  submit() {
    this.element.submit();
  }
}
