import Blacklight from 'blacklight-frontend'

Blacklight.onLoad(() => {
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  popoverTriggerList.forEach((popoverTriggerEl) => {
    let popover = new bootstrap.Popover(popoverTriggerEl, {
      // needed to be able to set a data-controller on popover
      // popover controller allows us to have a dimissible popover
      // that doesn't disappear when users copy/interact with the popover
      template: `<div class="popover" role="tooltip" data-controller="popover">
                  <div class="popover-arrow"></div>
                  <div class="popover-header">
                  </div>
                  <div class="popover-body">
                  </div>
                  </div>`,
      // tags and attributes allowed in the popover, everything not listed will be stripped
      // needed to be able to put a data-controller and data-action in popover
      allowList: {
        '*': ['class', 'role', 'data-controller', 'data-action', 'aria-*'], // allow data-custom and data-another
        div: ['class', 'role', 'data-action', 'data-controller'],
        button: ['data-action'],
        i: ['class']
      }
    })
  })
});
