// Entry point for the build script in your packageon

import "@hotwired/turbo-rails";
import "./vendor/responsiveTruncator";
import "./vendor/jquery-scrollspy";
import "blacklight-frontend/app/assets/javascripts/blacklight/blacklight";

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({ onLoadHandler: Blacklight.onLoad });

import "./alternate_catalog";
import "./analytics";
import "./article";
import "./async_collection_members";
import "./course_reserves";
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
import "./jquery.purl-embed";
import "./jquery.side-nav-minimap";
import "./jquery.stackmap";
import "./libraryh3lp";
import "./location-hours";
import "./preview-content";
import "./recent-selections";
import "./select-all";
import "./sfx-panel";
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
