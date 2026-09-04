import handleFrameFetchRequest from "./handleFrameFetchRequest.js"
import handleFilmstripFrameMissing from "./handleFilmstripFrameMissing.js"

// This module must be loaded before Turbo. When the application bundle is deferred,
// Turbo upgrades eager frames as soon as it starts and their fetch events would
// otherwise fire before these handlers are registered.
document.addEventListener("turbo:before-fetch-request", handleFrameFetchRequest)
document.addEventListener("turbo:frame-missing", handleFilmstripFrameMissing)

// Prevent the back-button from trying to add a second instance of recaptcha.
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function() {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "")
})
