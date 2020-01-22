(function( global) {
  'use strict';
  var ExhibitsPanel;

  ExhibitsPanel = {
    panel: null,
    druid: null,
    exhibitsHost: null,
    isCollection: null,
    exhibitToggleThreshold: 5,

    init: function(panel) {
      this.panel = panel;
      this.druid = this.panel.data('druid');
      this.exhibitsHost = this.panel.data('exhibitsHost');
      this.isCollection = this.panel.data('isCollection');

      if (panel.find('.media').length === 0) { // Only run the fetch if the panel has no exhibits yet
        this.fetchExhibits();
      } else {
        this.addToggleLinkBehavior(); // Add toggleLinkBehavior if inited with exhibits already (e.g. back button click)
      }
    },

    fetchExhibits: function() {
      var _this = this;

      $.ajax({
        url: _this.exhibitsHost + "/exhibit_finder/" + _this.druid,
        dataType: 'json'
      }).done(function(data) {
        if (data.length === 0) {
          return;
        }

        _this.showAppropriatePanelHeading(data.length);

        $.each(data, function(i, exhibit) {
          _this.panel.find('.panel-body').append(_this.exhibitMediaObject(exhibit));
        });

        _this.addToggleLinkBehavior();

        $('[data-behavior="metadata-panel-context-heading"]').show(); // Ensure heading is displayed
        _this.panel.show();
      });
    },

    exhibitsUrl: function(slug) {
      var baseExhibitUrl = this.exhibitsHost + '/' + slug;
      if (this.isCollection) {
        return baseExhibitUrl;
      } else {
        return baseExhibitUrl + '/catalog/' + this.druid;
      }
    },

    showAppropriatePanelHeading: function(exhibitCount) {
      if (exhibitCount > 1) {
        this.panel.find('[data-behavior="multiple-exhibit-heading"]').show();
      } else {
        this.panel.find('[data-behavior="single-exhibit-heading"]').show();
      }
    },

    addToggleLinkBehavior: function() {
      var _this = this;
      var container = _this.panel.find('.panel-body');
      var exhibitMediaObjects = container.find('.media');
      var exhibitCount = exhibitMediaObjects.length;
      if (exhibitCount >= _this.exhibitToggleThreshold) {
        if (container.find('a.see-all-exhibits').length > 0) {
          var toggleLink = container.find('a.see-all-exhibits');
        } else {
          var toggleLink = $('<a class="see-all-exhibits" href="#">See all ' + exhibitCount + ' exhibits</a>');
        }

        var exhibitMediaObjects = container.find('.media');
        exhibitMediaObjects.each(function(i) {
          if (i >= _this.exhibitToggleThreshold) {
            $(this).hide();
          }
        });
        toggleLink.on('click.see-all-exhibits-link', function(e) {
          e.preventDefault();

          // We don't have good text for a toggle off link.
          // When we do we can remove this and update the text appropriately
          toggleLink.remove();
          exhibitMediaObjects.each(function(i) {
            if (i >= _this.exhibitToggleThreshold) {
              if($(this).is(':visible')) {
                $(this).hide(); // Will be used when we have a toggle closed link
              } else {
                $(this).show();
              }
            }
          });
        });


        // Don't add the link if it's already there (back-button click)
        if (container.find(toggleLink).length === 0 ) {
          container.append(toggleLink);
        }
      }
    },

    exhibitMediaObject: function(exhibit) {
      var exhibitUrl = this.exhibitsUrl(exhibit.slug);
      var wrapper = $('<div class="media"></div>');
      var image = $(
        '<div class="media-left"><a href="' + exhibitUrl + '"><img src="" /></a></div>'
      );
      var body = $('<div class="media-body"></div>');
      var heading = $('<div class="media-heading"></div>');
      if (exhibit.thumbnail_url) {
        wrapper.append(image);
        image.find('img').prop('src', exhibit.thumbnail_url);
      }
      wrapper.append(body);
      body.append(heading);
      heading.append(
        '<h4><a href="' + exhibitUrl + '">' + exhibit.title + '</a></h4> '
      );
      if (exhibit.subtitle && exhibit.subtitle !== '') {
        heading.append(exhibit.subtitle)
      }
      return wrapper;
    }
  }

  global.ExhibitsPanel = ExhibitsPanel;
})(this);

Blacklight.onLoad(function() {
  $('[data-behavior="exhibits-panel"]').each(function(i, element) {
    ExhibitsPanel.init($(element));
  })
});
