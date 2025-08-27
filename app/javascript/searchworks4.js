// Entry point for the build script in your packageon

import "@hotwired/turbo-rails"
import "blacklight-frontend"

import "./popover"
import "./range-limit"

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "")
});

import "./controllers"
import "./controllers/external"

import './turbo'
