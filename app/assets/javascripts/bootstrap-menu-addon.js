Blacklight.onLoad(function(){
  var toggle   = '[data-toggle="dropdown"]';
  var menu     = '.dropdown-menu';
  // Remove bootstrap dropdown's keydown events and substitute our own
  $(document).off('keydown.bs.dropdown.data-api', '[data-toggle="dropdown"]');
  $(document).off('keydown.bs.dropdown.data-api', '.dropdown-menu');

  $(document).on('keydown.bs.dropdown.data-api', '[data-toggle="dropdown"]', keydownDropdownOverride);
  $(document).on('keydown.bs.dropdown.data-api', '.dropdown-menu', keydownDropdownOverride);

  // Overridden from Bootstrap (as a direct copy)
  function getParent($this) {
    var selector = $this.attr('data-target')

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#[A-Za-z]/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') // strip for ie7
    }

    var $parent = selector !== '#' ? $(document).find(selector) : null

    return $parent && $parent.length ? $parent : $this.parent()
  }

  // This event mimics the behavior in Bootstrap's Dropdown.prototype.keydown
  // except it adds some additional keyboard functionality.
  function keydownDropdownOverride(e) {
    if (!/(38|40|27|32|36|35)/.test(e.which) || /input|textarea/i.test(e.target.tagName)) return

    var $this = $(this)

    e.preventDefault()
    e.stopPropagation()

    if ($this.is('.disabled, :disabled')) return

    var $parent  = getParent($this)
    var isActive = $parent.hasClass('open')

    if (!isActive && e.which != 27 || isActive && e.which == 27) {
      if (e.which == 27) $parent.find(toggle).trigger('focus')
      return $this.trigger('click')
    }

    var desc = ' li:not(.disabled):visible a'
    var $items = $parent.find('.dropdown-menu' + desc)

    if (!$items.length) return

    var index = $items.index(e.target)

    // Add Home/End key support (not available in Bootstrap)
    if (e.which == 35) {
      index = $items.length - 1
    }

    if (e.which == 36) {
      index = 0
    }

    // The Up/Down branches below are what we've overriden from Bootstrap
    // Up
    if (e.which == 38) {
      if (index == 0) {
        index = $items.length - 1
      } else if (index > 0) {
        index--
      }
    }

    // Down
    if (e.which == 40) {
      if (index == $items.length - 1) {
        index = 0
      } else if (index < $items.length - 1) {
        index++
      }
    }

    if (!~index)    index = 0

    $items.eq(index).trigger('focus')

  }

  $(toggle).parent().on('shown.bs.dropdown updated.selections.dropdown', function() {
    var dropdown = $(this);
    var menu = dropdown.find('.dropdown-menu');
    var links = menu.children().find('a');
    links.first().focus();
  });

  // Ensure the menu is closed when tabbing out
  $(toggle).parent().find(menu).on('keydown', function(e) {
    if(e.key === 'Tab') {
      $(this).parent().find(toggle).dropdown('toggle');
    }
  });
});
