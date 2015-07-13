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
      var openAnnoUrl = $(this).data('annoStoreUrl'),
          $container = $(this),
          $formAnnotations = $container.find('.form-annotations'),
          hasTargetPrefix = "http://searchworks.stanford.edu/view/",
          data = { 'utf8': '✓' };

          tplAnnoJsonLd = {
            "@context": "http://www.w3.org/ns/oa.jsonld",
            "@graph": {
              "@type": "oa:Annotation",
              "hasTarget": "",
              "motivatedBy": "",
              "hasBody": {
                "@type": [
                  "dctypes:Text",
                  "cnt:ContentAsText"
                ],
                "chars": "",
                "format": "text/plain",
                "language": "en"
              }
            }
          };

      init();

      function init() {
        $container.on('submit', 'form.form-annotations', function(event) {
          fetchParams();
          $formAnnotations.find('input[type="submit"]').text('Saving...');
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
        data['authenticity_token'] = $formAnnotations.find('input#oa-store-authenticity-token').val();

        tplAnnoJsonLd['@graph']['hasBody']['chars'] = $formAnnotations.find('.text-annotation').val();
        tplAnnoJsonLd['@graph']['hasTarget'] = hasTargetPrefix + $formAnnotations.find('input#annotation_hasTarget_id').val();
        motivation = $formAnnotations.find('input#annotation_motivatedBy').val();
        tplAnnoJsonLd['@graph']['motivatedBy'] = "oa:" + motivation

        if (motivation.valueOf() == "tagging") {
          tplAnnoJsonLd['@graph']['hasBody']['@type'].push(new String("oa:Tag"))
        }

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
  $('#create-tag').saveAnnotations();
  $('#create-comment').saveAnnotations();
});

