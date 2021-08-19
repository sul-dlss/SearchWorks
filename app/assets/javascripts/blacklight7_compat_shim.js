// Blacklight 7 compatibility:
if (Blacklight.modal === undefined) {
  Blacklight.modal = {};
}

Blacklight.modal.modalSelector = "#ajax-modal";
Blacklight.ajaxModal.triggerLinkSelector  = "a[data-ajax-modal~=trigger],a[data-blacklight-modal~=trigger],  a.lightboxLink,a.more_facets_link,.ajax_modal_launch";

(function ($) {
  $.fn.tooltip.Constructor.prototype._fixTitle = $.fn.tooltip.Constructor.prototype.fixTitle;
})(jQuery);
