;(function ($, window, document, undefined ) {
  'use strict';
  
  // Create the defaults once
  var pluginName = "managedPurl";
  var defaults = {};
  var $el;

  function Plugin(element, options) {
    $el = $(element);
    
    this.options = $.extend({}, defaults, options);
    this._defaults = defaults;
    this._name = pluginName;
    
    this.init();
  }

  Plugin.prototype = {
    init: function() {
      this.embedIframe($el[0].querySelector('button'));
      this.setupListeners();
    },
    setupListeners: function() {
      var _this = this;
      $el.find('button').on('click', function(e, f) {
        $el.find('li').removeClass('active');
        _this.embedIframe(this);
      });
    },
    embedIframe: function(button) {
      button.parentElement.classList.add('active')
      const data = button.dataset
      const provider = data.embedProvider.replace(/\/embed$/, '/iframe')
      const url = `${provider}?url=${data.embedTarget}&hide_title=true&maxheight=500`
      const embedArea = document.querySelector('.managed-purl-embed')
      embedArea.innerHTML = `<iframe src="${url}" frameborder=0 width="100%" scrolling="no" ` +
      `allowfullscreen=true style="height: 520px;"><iframe>`
    }
  };

  // A really lightweight plugin wrapper around the constructor,
  // preventing against multiple instantiations
  $.fn[pluginName] = function ( options ) {
    return this.each(function () {
      if (!$.data(this, "plugin_" + pluginName)) {
        $.data(this, "plugin_" + pluginName,
        new Plugin( this, options ));
      }
    });
  };

})(jQuery, window, document);

Blacklight.onLoad(function() {
  $('.managed-purl-panel').managedPurl();
});
