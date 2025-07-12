import Blacklight from 'blacklight-frontend'

class SelectUnSelectAll {
  /*
    Class for selecting/unselecting bookmarks

      Usage: new SelectUnSelectAll(element);
  */

  constructor(element) {
    this.element = element;
    this.selectAll = element.querySelector('span.select-all');
    this.unSelectAll = element.querySelector('span.unselect-all');
    this.selectorSelectBookmarks = 'input.toggle-bookmark';

    this.setInitialAction();
    this.init();
  }

  init() {
    this.element.addEventListener('click', () => this.toggleAll());
  }

  toggleAll() {
    const state = this.selectAll.style.display !== 'none';
    document.querySelectorAll(this.selectorSelectBookmarks).forEach(async (checkbox, index) => {
      if (checkbox.checked !== state) {
        const event = new MouseEvent("click", {
          view: window,
          bubbles: true,
          cancelable: true,
        })
        checkbox.dispatchEvent(event)
      }
      if (index > 20) {
        // Avoid trigging DOS protection in the loadbalancer.
        await new Promise(r => setTimeout(r, 500))
      }
    })

    this.toggleActions()
  }

  setInitialAction() {
    if (document.querySelectorAll(this.selectorSelectBookmarks + ':checked').length !== 0) {
      this.toggleActions();
    }
  }

  toggleActions() {
    this.selectAll.style.display = this.selectAll.style.display === 'none' ? '' : 'none';
    this.unSelectAll.style.display = this.unSelectAll.style.display === 'none' ? '' : 'none';
  }
}

Blacklight.onLoad(function() {
    const selectAllDropdown = document.getElementById('select_all-dropdown');
    if (selectAllDropdown) {
      new SelectUnSelectAll(selectAllDropdown);
    }
});
