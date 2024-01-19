// Entry point for the build script in your packageon

import "@hotwired/turbo-rails";
import "./vendor/responsiveTruncator";
import "./vendor/jquery-scrollspy";
import "leaflet";
// import "popper.js";
// import "bootstrap";
import "blacklight-frontend/app/assets/javascripts/blacklight/blacklight";
import "blacklight-range-limit";
import "blacklight-range-limit/vendor/assets/javascripts/bootstrap-slider"

import "./alternate_catalog";
import "./analytics";
import "./article";
import "./async_collection_members";
import "./backend_lookup";
import "./blacklight_hierarchy";
import "./bootstrap-modal-addon";
import "./course_reserves";
import "./eds_range_limit";
import "./embedded-call-number-browse";
import "./exhibitPanel";
import "./facet-options-checkboxes";
import "./feedback_form";
import "./home_page_facet_collapse";
import "./jquery.accordion-section";
import "./jquery.clear-input-text";
import "./jquery.libraryh3lp";
import "./jquery.live-lookup";
import "./jquery.long-lists";
import "./jquery.managed-purl";
import "./jquery.plug-google-content";
import "./jquery.preview-brief";
import "./jquery.preview-embed-browse";
import "./jquery.preview-filmstrip";
import "./jquery.preview-gallery";
import "./jquery.purl-embed";
import "./jquery.side-nav-minimap";
import "./jquery.stackmap";
import "./jquery.turbolinks-cursor";
import "./location-hours";
import "./preview-content";
import "./recent-selections";
import "./search-context";
import "./select-all";
import "./sfx-panel";
import "./skip-to-nav";
import "./tooltip";
import "./truncate";
import "./update-hidden-inputs-by-checkbox";

// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "");
});
