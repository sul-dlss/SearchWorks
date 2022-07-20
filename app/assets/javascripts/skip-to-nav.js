// Inspired from https://www.nczonline.net/blog/2013/01/15/fixing-skip-to-content-links/

Blacklight.onLoad(function() {
  function setFocusBehaviorForExistingURLHashes() {
    var locationHash = location.hash.substring(1);
    if (locationHash) {
      var clickElement = $('[href="#' + locationHash + '"]');
      var targetElement = $('#' + locationHash);
      removeTabIndex(targetElement);
      targetElement.focus();
      clickElement.on('click', function() {
        targetElement.focus();
      });
    }
  }

  function removeTabIndex(element) {
    if (element && isTabbableElement(element)) {
      element.attr('tabIndex', -1);
    }
  }

  function isTabbableElement(element) {
    return (!/^(?:a|select|input|button|textarea)$/i.test(element.attr('name')));
  }

  setFocusBehaviorForExistingURLHashes();

  window.addEventListener('hashchange', function(event) {
    var element = $('#' + location.hash.substring(1));
    if (element) {
      removeTabIndex(element);
      element.focus();
    }
  }, false);
});
