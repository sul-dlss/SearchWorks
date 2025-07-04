// Entry point for the build script in your packageon

import "@hotwired/turbo-rails";
import "./vendor/responsiveTruncator";
import Blacklight from "blacklight-frontend";

import BlacklightRangeLimit from "blacklight-range-limit/app/assets/javascripts/blacklight_range_limit/blacklight_range_limit.esm";
import "blacklight-range-limit/vendor/assets/javascripts/bootstrap-slider"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.canvaswrapper"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.colorhelpers"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.event.drag"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.browser"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.drawSeries"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.hover"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.saturated"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.selection"
import "blacklight-range-limit/vendor/assets/javascripts/flot/jquery.flot.uiConstants"
Blacklight.onLoad(function() {
  BlacklightRangeLimit.initialize(Blacklight.Modal.modalSelector)
});

import "./alternate_catalog";
import "./article";
import "./call-number-browse-tabs";
import "./eds_range_limit";
import "./facet-options-checkboxes";
import "./feedback_form";
import "./location-hours";
import "./purl-embed";
import "./recent-selections";
import "./select-all";
import "./tooltip";
import "./popover";
import "./truncate";

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "");
});

import "./controllers"
import "./controllers/external"
