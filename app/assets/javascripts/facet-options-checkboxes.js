/*
  JavaScript module to handle the behavior of the "Search settings" checkbox options
 */

var FacetOptionsCheckboxes = (function() {
  var parentSelector = '[data-behavior="facet-options-checkboxes"]';
  var itemSelector = '[data-behavior="facet-options-checkbox"]';
  var loadingSpinnerSelector = '[data-behavior="loading-spinner"]';


  function parentEl() {
    return $(parentSelector);
  }

  function checkboxItems() {
    return parentEl().find(itemSelector);
  }

  function loadingSpinner() {
    return parentEl().find(loadingSpinnerSelector);
  }

  function disableAllLinksExcept(href) {
    checkboxItems().each(function() {
      if(href != $(this).find('a').prop('href')) {
        $(this).find('a').prop('href', '#');
      }
      $(this).find('input[type="checkbox"]').prop('disabled', true);
    });
  }

  function toggleCheckbox(checkbox) {
    checkbox.prop('checked', !checkbox.prop('checked'));
  }

  return {
    init: function() {
      var _this = this;
      checkboxItems().each(function() {
        var $checkboxLink = $(this);
        var $checkbox = $(this).find('input[type="checkbox"]');

        // When the checkbox is clicked, its state it toggled.
        // In order to have our link's click handler correctly
        // set this state in all cases, we need to reverse it.
        // preventDefault and stopPropagation doesn't seem to work.
        $checkbox.on('click', function() {
          toggleCheckbox($checkbox);
          $checkboxLink.find('a')[0].click();
        });

        $checkboxLink.find('a').on('click', function(e) {
          if (!$checkbox.prop('disabled')) {
            toggleCheckbox($checkbox);
            _this.enableLoadingSpinner();
            disableAllLinksExcept($(this).prop('href'));
          }
        });
      });
    },

    enableLoadingSpinner: function() {
      loadingSpinner().show();
    }
  };

}());

Blacklight.onLoad(function() {
  FacetOptionsCheckboxes.init();
});
