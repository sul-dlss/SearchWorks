(function($) {
  /*
    jQuery plugin to fetch and render annotations

      Usage: $(selector).showAnnotations();

    This plugin :
      - fetches annotations (comments & tags) for a target_url
      - renders annotations with appropriate styles
  */

  $.fn.showAnnotations = function() {

    return this.each(function() {
      var baseUrlSW = "searchworks.stanford.edu/view/",
          openAnnoUrl = "https://triannon-dev.stanford.edu/solr/select?defType=lucene&wt=json&",
          $documents = $(this),
          listRecords = $documents.find('[data-anno-id]'),
          targetUrls = [],
          annotations = {};

      init();

      function init() {
        $.each(listRecords, function(index, record) {
          targetUrls.push(baseUrlSW + $(record).data('annoId'));
        });

        fetchAnnotations();
      }

      function fetchAnnotations() {
        var targetUrl = targetUrls.join(' OR '),
            request;

        request = $.ajax({
          url: openAnnoUrl,
          type: "GET",
          data: { q: 'target_url:(' + targetUrl + ')'},
          dataType: 'jsonp',
          jsonp: 'json.wrf'
        });

        request.success(function(response) {
          var numFound = parseInt(response.response.numFound, 10);

          if (numFound > 0) {
            aggregateAnnotations(response);
          }
        });
      }

      function aggregateAnnotations(response) {
        var docs = response.response.docs;

        $.each(docs, function(index, doc) {
          var id = doc.target_url[0].replace(new RegExp('^.*' + baseUrlSW), ''),
              motivation = doc.motivation[0],
              bodyChars = doc.body_chars_exact[0];

          if (bodyChars !== '') {
            annotations[id] = annotations[id] || {};
            annotations[id][motivation] = annotations[id][motivation] || [];
            annotations[id][motivation].push(bodyChars);
          }
        });

        if ($documents.find('.record-sections').length > 0) {
          displayAnnotationsInRecordView();
        } else {
          displayAnnotationsInSearchResults();
        }
      }

      function displayAnnotationsInRecordView() {
        $.each(annotations, function(id, values) {
          var $sectionUserComments = $documents.find('.annotations-user-comments[data-anno-id=' + id + ']'),
              $sectionTags = $documents.find('.annotations-tags[data-anno-id=' + id + ']'),
              html = [];

          if (values.commenting && values.commenting.length > 0) {
            $.each(values.commenting, function(index, comment) {
              html.push($('<li>' + comment + '</li>'));
            });

            $sectionUserComments.find('.user-comments ul').empty().append(html);
            $sectionUserComments.find('.num-found').html('(' + values.commenting.length + ')');
            $sectionUserComments.show();
          }

          addTags($sectionTags, values.tagging);
        });
      }

      function displayAnnotationsInSearchResults() {
        $.each(annotations, function(id, values) {
          var $record = $documents.find('[data-anno-id=' + id + ']'),
              html = [];

          if (values.commenting && values.commenting.length > 0) {
            $record.find('.num-found').html(values.commenting.length);
            $record.find('.user-comments').show();
            $record.show();
          }

          addTags($record, values.tagging);
          $record.parent().css('padding-bottom', 0);
        });
      }

      function addTags($el, tags) {
        var html = [];

        if (tags && tags.length > 0) {
          $.each(tags, function(index, tag) {
            html.push($('<span class="tag">' + tag + '<span class="arrow"></span></span>'));
          });

          $el.find('.tags').empty().append(html);
          $el.show();
        }
      }

    });
  }

})(jQuery);

Blacklight.onLoad(function() {
  $('#documents').showAnnotations();
  $('#document').showAnnotations();
});

