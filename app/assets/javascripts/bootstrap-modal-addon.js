Blacklight.onLoad(function(){
  // // Update aria-hidden and aria-modal attributes when the bootstrap modal is shown/hidden
  // // This is addressed in Bootstrap 4 https://github.com/twbs/bootstrap/issues/19878
  // // This strategy tries to mimic what happens when toggling modals in Bootstrap 4 (wrt aria attributes)
  // var modalSelector = Blacklight.modal.modalSelector;
  // $(modalSelector).on('shown.bs.modal', function() {
  //   if($(this)[0].hasAttribute('aria-hidden')) {
  //     $(this).removeAttr('aria-hidden');
  //   }
  //
  //   if(!$(this)[0].hasAttribute('aria-modal')) {
  //     $(this).attr('aria-modal', true);
  //   }
  // });
  //
  // $(modalSelector).on('hidden.bs.modal', function() {
  //   if(!$(this)[0].hasAttribute('aria-hidden')) {
  //     $(this).attr('aria-hidden', true);
  //   }
  //
  //   if($(this)[0].hasAttribute('aria-modal')) {
  //     $(this).removeAttr('aria-modal');
  //   }
  // });
});
