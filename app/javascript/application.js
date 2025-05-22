// Entry point for the build script in your packageon

import "@hotwired/turbo-rails";
import "./vendor/responsiveTruncator";
import "./vendor/jquery-scrollspy";
import "blacklight-frontend/app/assets/javascripts/blacklight/blacklight";

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
import "./analytics";
import "./article";
import "./eds_range_limit";
import "./embedded-call-number-browse";
import "./exhibitPanel";
import "./facet-options-checkboxes";
import "./feedback_form";
import "./home_page_facet_collapse";
import "./jquery.clear-input-text";
import "./jquery.managed-purl";
import "./jquery.plug-google-content";
import "./jquery.preview-embed-browse";
import "./jquery.preview-gallery";
import "./jquery.side-nav-minimap";
import "./jquery.stackmap";
import "./libraryh3lp";
import "./location-hours";
import "./preview-content";
import "./purl-embed";
import "./recent-selections";
import "./select-all";
import "./tooltip";
import "./popover";
import "./truncate";
import "./update-hidden-inputs-by-checkbox";

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "");
});

import "./controllers"
import "./controllers/external"
