// Entry point for the build script in your packageon

import "@hotwired/turbo-rails";
import "./vendor/responsiveTruncator";
import "./vendor/jquery-scrollspy";
// import "popper.js";
// import "bootstrap";
import "blacklight-frontend/app/assets/javascripts/blacklight/blacklight";

// undo Blacklight's count resizing (incompatible with Blacklight 8 markup)
Blacklight.doResizeFacetLabelsAndCounts = function() {};


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
  modalSelector = Blacklight.modal?.modalSelector || Blacklight.Modal.modalSelector;
  BlacklightRangeLimit.initialize(modalSelector);

  document.addEventListener('click', (e) => {
    if (e.target.closest('[data-bl-dismiss="modal"]')) Blacklight.modal.hide();
  });
});

import "./alternate_catalog";
import "./analytics";
import "./article";
import "./async_collection_members";
import "./course_reserves";
import "./eds_range_limit";
import "./embedded-call-number-browse";
import "./exhibitPanel";
import "./facet-options-checkboxes";
import "./feedback_form";
import "./home_page_facet_collapse";
import "./jquery.accordion-section";
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

// TODO: Remove this whole method when we upgrade to Blacklight 8, provided that
//       https://github.com/projectblacklight/blacklight/pull/3133 is merged
//
// Add the passed in contents to the modal and display it.
// We have specific handling so that scripts returned from the ajax call are executed.
// This enables adding a script like recaptcha to prevent bots from sending emails.
Blacklight.modal.receiveAjax = function (contents) {
  const domparser = new DOMParser();
  const dom = domparser.parseFromString(contents, "text/html")
  // If there is a containerSelector on the document, use its children.
  let elements = dom.querySelectorAll(`${Blacklight.modal.containerSelector} > *`)
  const frag = document.createDocumentFragment()
  if (elements.length == 0) {
    // If the containerSelector wasn't found, use the whole document
    elements = dom.body.childNodes
  }
  elements.forEach((el) => frag.appendChild(el))

  // DOMParser doesn't allow scripts to be executed.  This fixes that.
  frag.querySelectorAll('script').forEach((script) => {
    const fixedScript = document.createElement('script')
    fixedScript.src = script.src
    fixedScript.async = false
    script.parentNode.replaceChild(fixedScript, script)
  })

  document.querySelector(`${Blacklight.modal.modalSelector} .modal-content`).replaceChildren(frag)

  Blacklight.modal.show();
};


// Prevent the back-button from trying to add a second instance of recaptcha
// See https://github.com/ambethia/recaptcha/issues/217#issuecomment-615221808
document.addEventListener("turbo:before-cache", function () {
  // On the articles page there is a feedback and a connection form.
  // Both have a recaptcha that needs clearing.
  document.querySelectorAll(".g-recaptcha").forEach((elem) => elem.innerHTML = "");
});

import "./controllers"
import "./controllers/external"
