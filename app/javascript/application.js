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
