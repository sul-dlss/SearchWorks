/*
  JavaScript module to fetch preview content. `useCache` option enables/disables
  caching of fetched preview content in browser
 */

const PreviewContent = (function() {

  var useCache = true,
    insertType;

  window.previewCache = window.previewCache || {};

  function checkCache(url, target, deferred) {
    var content = window.previewCache[url];

    if (useCache && typeof content !== 'undefined') {
      plugContentAndPlugins(target, content, deferred);
    } else {
      fetchContentViaAjaxAndInsert(url, target, deferred);
    }
  }


  function fetchContentViaAjaxAndInsert(url, target, deferred) {
    var request = $.ajax({
      url: url,
      type: 'GET',
      dataType: 'html'
    });

    request.done(function(data) {
      plugContentAndPlugins(target, data, deferred);
      if (useCache) window.previewCache[url] = data;
    });

    request.fail(function(jqXhr, textStatus) {
      console.log('GET request for ' + url + ' failed: ' + textStatus);
    });
  }


  function plugContentAndPlugins(target, content, deferred) {
    switch (insertType){
    case 'append':
      target
        .append(content)
        .plugGoogleBookContent();

      target.find('*[data-accordion-section-target]').accordionSection();
      target.find('[data-live-lookup-url]').liveLookup();
      deferred.resolve(content);
      break;
    case 'prepend':
      target
        .prepend(content)
        .plugGoogleBookContent();

      target.find('*[data-accordion-section-target]').accordionSection();
      target.find('[data-live-lookup-url]').liveLookup();
      deferred.resolve(content);
      break;
    case 'returnOnly':
      deferred.resolve(content);
      break;

    }

  }

  return {
    append: function(url, target) {
      insertType = 'append';
      var deferred = new $.Deferred();
      checkCache(url, target, deferred);
      return deferred.promise();
    },
    prepend: function(url, target) {
      insertType = 'prepend';
      var deferred = new $.Deferred();
      checkCache(url, target, deferred);
      return deferred.promise();
    },
    returnOnly: function(url, target) {
      insertType = 'returnOnly';
      var deferred = new $.Deferred();
      checkCache(url, target, deferred);
      return deferred.promise();
    }
  };

}());

export default PreviewContent;