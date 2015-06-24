(function($) {
  /*
    jQuery plugin to save user-created annotations

      Usage: $(selector).saveAnnotations();

    This plugin :
      - reads annotations text from forms
      - packages data in JSON-LD and posts to annotations server
  */

  $.fn.saveAnnotations = function() {

    return this.each(function() {
      var openAnnoUrl = "https://triannon-dev.stanford.edu/annotations/sw",
          $container = $(this),
          $formAnnotations = $container.find('.form-annotations'),
          hasTargetPrefix = "http://searchworks.stanford.edu/view/",
          data = { 'utf8': '✓' };

          tplAnnoJsonLd = {
            "@context": "http://www.w3.org/ns/oa.jsonld",
            "@graph": [
              {
                "@id": "_:g70289608390920",
                "@type": [
                  "dctypes:Text",
                  "cnt:ContentAsText"
                ],
                "chars": "",
                "format": "text/plain",
                "language": "en"
              },
              {
                "@type": "oa:Annotation",
                "hasBody": "_:g70289608390920",
                "hasTarget": "",
                "motivatedBy": ""
              }
            ]
          };

      init();

      function init() {
        $container.on('submit', 'form.form-annotations', function(event) {
          fetchParams();
          $formAnnotations.find('button[type="submit"]').text('Saving...');
          postAnnotation();
          event.preventDefault();
        });

        $container.parent().find('.btn-add-annotation').on('click', function() {
          $formAnnotations.parent().slideToggle('fast');
          $formAnnotations.find('.text-annotation').focus();
        });

        $container.find('a.cancel-link').on('click', function(event) {
          $formAnnotations.parent().slideUp('fast');
          $formAnnotations.find('.text-annotation').blur();
          event.preventDefault();
        });

      }

      function fetchParams() {
        data['authenticity_token'] = $formAnnotations.find('input#authenticity-token').val();

        tplAnnoJsonLd['@graph'][0]['chars'] = $formAnnotations.find('.text-annotation').val();
        tplAnnoJsonLd['@graph'][1]['hasTarget'] = hasTargetPrefix + $formAnnotations.find('input#sw-id').val();
        tplAnnoJsonLd['@graph'][1]['motivatedBy'] = $formAnnotations.find('input#motivation').val();

        data["annotation[data]"] = JSON.stringify(tplAnnoJsonLd);
      }

      function postAnnotation() {
        var request = $.ajax({
          url: openAnnoUrl,
          type: "POST",
          data: data,
          contentType: 'application/x-www-form-urlencoded'
        });

        request.success(function(response) {
        });

        request.error(function(error) {
          console.log('Error positing annotation - ', error);
        });

        request.complete(function() {
          // $formAnnotations.parent().slideUp('fast');
          location.reload();
        });

      }

    });
  }

})(jQuery);

Blacklight.onLoad(function() {
  $('#create-tags').saveAnnotations();
  $('#create-comments').saveAnnotations();
});

