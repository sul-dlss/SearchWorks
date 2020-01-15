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
      this.fetchExhibits();
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

        var panelBody = _this.panel.find('.panel-body');
        $.each(data, function(i, exhibit) {
          panelBody.append(_this.exhibitMediaObject(exhibit));
        });

        _this.addToggleLinkBehavior(panelBody, data.length);

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

    addToggleLinkBehavior: function(container, exhibitCount) {
      var _this = this;
      if (exhibitCount >= _this.exhibitToggleThreshold) {
        var toggleLink = $('<a href="#">See all ' + exhibitCount + ' exhibits</a>');
        var exhibitMediaObjects = container.find('.media');
        exhibitMediaObjects.each(function(i) {
          if (i >= _this.exhibitToggleThreshold) {
            $(this).hide();
          }
        });
        toggleLink.on('click', function(e) {
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
        container.append(toggleLink);
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
