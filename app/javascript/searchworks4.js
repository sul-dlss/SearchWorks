// Entry point for the build script in your packageon

import "@hotwired/turbo-rails"
import "blacklight-frontend"

import './article'
import "./popover"
import "./feedback_form"
import "./responsive-aside"
import "./purl-embed"
import "./range-limit"

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "")
});

import "./controllers"
import "./controllers/external"
