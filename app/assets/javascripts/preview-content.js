/*
  JavaScript module to fetch preview content. `useCache` option enables/disables
  caching of fetched preview content in browser
 */

var PreviewContent = (function() {

  var useCache = true,
    insertType;

  window.previewCache = window.previewCache || {};

  function checkCache(url, target, defered) {
    var content = window.previewCache[url];

    if (useCache && typeof content !== 'undefined') {
      plugContentAndPlugins(target, content);
    } else {
      fetchContentViaAjaxAndInsert(url, target, defered);
    }
  }


  function fetchContentViaAjaxAndInsert(url, target, defered) {
    var request = $.ajax({
      url: url,
      type: 'GET',
      dataType: 'html'
    });

    request.done(function(data) {
      plugContentAndPlugins(target, data);
      if (useCache) window.previewCache[url] = data;
      defered.resolve(data);
    });

    request.fail(function(jqXhr, textStatus) {
      console.log('GET request for ' + url + ' failed: ' + textStatus);
    });
  }


  function plugContentAndPlugins(target, content) {
    switch (insertType){
    case 'append':
      target
        .append(content)
        .plugGoogleBookContent()
        .find('.image-filmstrip').renderFilmstrip();
      Blacklight.do_bookmark_toggle_behavior();
      break;
    case 'prepend':
      target
        .prepend(content)
        .plugGoogleBookContent()
        .find('.image-filmstrip').renderFilmstrip();
      Blacklight.do_bookmark_toggle_behavior();
      break;
    case 'returnOnly':
      break;

    }

  }

  return {
    append: function(url, target) {
      insertType = 'append';
      var defered = new $.Deferred();
      checkCache(url, target, defered);
      return defered.promise();
    },
    prepend: function(url, target) {
      insertType = 'prepend';
      var defered = new $.Deferred();
      checkCache(url, target, defered);
      return defered.promise();
    },
    returnOnly: function(url, target) {
      insertType = 'returnOnly';
      var defered = new $.Deferred();
      checkCache(url, target, defered);
      return defered.promise();
    }
  };

}());
