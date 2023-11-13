import { Application } from "@hotwired/stimulus"
// application.js
import { Turbo } from "@hotwired/turbo-rails"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
