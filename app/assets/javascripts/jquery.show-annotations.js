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
      var $annotationEl = $(this),
          $annotationUrl = $annotationEl.data('annoUrl');

      init();

      function init() {
        $.ajax($annotationUrl)
         .success(function(data) {
           addAnnotations(data);
         });
      }

      function addAnnotations(data) {
        renderTags(tags(data));
        renderComments(comments(data));
        $annotationEl.show();
      }

      function tags(data) {
        return fetchContentFromData(data, 'tag');
      }

      function comments(data) {
        return fetchContentFromData(data, 'content');
      }

      function fetchContentFromData(data, type) {
        var content = [];
        $.each(data, function(_, annotation) {
          if( annotation.hasBody[0][type] ) {
            content.push(annotation.hasBody[0][type][0]);
          }
        });
        return content;
      }

      function renderTags(tags) {
        var tagsSection = $annotationEl.find('.tags');
        if(tags.length > 0) {
          $.each(tags, function(_, tag) {
            tagsSection.append(tagTemplate(tag));
          });
        }
      }

      function renderComments(comments) {
        var commentsSection = $annotationEl.find('.user-comments');
        if(comments.length > 0) {
          if(commentsSection.length > 0) {
            var commentsList = $('<ul></ul>');
            $.each(comments, function(_, comment) {
              commentsList.append(commentTemplate(comment));
            });
            commentsSection.append(commentsList);  
          }
          updateCommentCount(comments);
        }
      }

      function updateCommentCount(comments) {
        if($annotationEl.find('.num-found').length > 0) {
          $annotationEl.find('.num-found').text('(' + comments.length + ')');
        }
      }

      function commentTemplate(comment) {
        return '<li>' + comment + '</li>';
      }

      function tagTemplate(tag) {
        return '<span class="tag">' + tag + '<span class="arrow"></span></span>';
      }

    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-anno-url]').showAnnotations();
});
