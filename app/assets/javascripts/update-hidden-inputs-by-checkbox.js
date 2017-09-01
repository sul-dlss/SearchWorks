/*
  JavaScript module to update add/remove a relevant hidden input
  on a different (targeted) part of the page. The use case for this
  is the checkbox on the article home page updating hidden inputs in
  the search form (since we don't wnat the form extending into the page)
 */

var UpdateHiddenInputsByCheckbox = (function() {
  var checkboxSelector = '[data-behavior="update-hidden-inputs-by-checkbox"]';

  function checkboxes() {
    return $(checkboxSelector);
  }

  function selectedCheckbox() {
    return $(checkboxSelector + ':checked');
  }

  function checkboxTarget(checkbox) {
    return $(checkbox.data('targetSelector'));
  }

  function addHiddenInput(checkbox) {
    var id = checkbox.prop('id');
    var name = checkbox.prop('name');
    var value = checkbox.prop('value');

    checkboxTarget(checkbox).append(
      $('<input type="hidden" id="hidden_' + id + '" name="' + name + '" value="' + value + '">')
    );
  }

  function removeHiddenInput(checkbox) {
    var selectorId = '#hidden_' + checkbox.prop('id');
    $(selectorId).remove();
  }

  return {
    init: function() {
      this.setInitialSelection();

      this.addOnChangeBehavior();
    },

    setInitialSelection: function() {
      addHiddenInput(selectedCheckbox());
    },

    addOnChangeBehavior: function() {
      checkboxes().each(function() {
        var $checkbox = $(this);

        $checkbox.on('change', function() {
          if ($checkbox.prop('checked')) {
            addHiddenInput($checkbox);
          } else {
            removeHiddenInput($checkbox);
          }
        });
      });
    }
  };

}());

Blacklight.onLoad(function() {
  UpdateHiddenInputsByCheckbox.init();
});
