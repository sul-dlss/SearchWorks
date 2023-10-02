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
      this.embedIframe($el.find('li').first());
      this.setupListeners();
    },
    setupListeners: function() {
      var _this = this;
      $el.find('li').on('click', function(e, f) {
        $el.find('li').removeClass('active');
        _this.embedIframe($(this));
      });
    },
    embedIframe: function($li) {
      $li.addClass('active');
      var data = $li.data();
      var $embedArea = $('.managed-purl-embed');
      var provider = data.embedProvider.replace(/\/embed$/, '/iframe');
      var iFrameHtml = '<iframe src="' +
                       provider + '?url=' + data.embedTarget +
                       '&hide_title=true&maxheight=500"' +
                       ' frameborder=0 width="100%" scrolling="no"' +
                       ' allowfullscreen=true' +
                       ' style="height: 520px;"><iframe>';
      $embedArea.html(iFrameHtml);
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
