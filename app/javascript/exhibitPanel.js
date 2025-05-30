const ExhibitsPanel = {
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

      if (panel.find('[data-exhibit-panel-target]').length === 0) { // Only run the fetch if the panel has no exhibits yet
        this.fetchExhibits();
      } else {
        this.addToggleButtonBehavior(); // Add toggleButtonBehavior if inited with exhibits already (e.g. back button click)
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
          _this.createExhibitMediaObject(exhibit, _this.panel.find('.card-body')[0])
        });

        _this.addToggleButtonBehavior();

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

    addToggleButtonBehavior: function() {
      var _this = this;
      var container = _this.panel.find('.card-body');
      const exhibitMediaObjects = container[0].querySelectorAll('[data-exhibit-panel-target]')
      const exhibitCount = exhibitMediaObjects.length;
      if (exhibitCount > _this.exhibitToggleThreshold) {
        if (container.find('button.see-all-exhibits').length > 0) {
          var toggleButton = container.find('button.see-all-exhibits');
        } else {
          var toggleButton = $('<button class="see-all-exhibits btn btn-secondary btn-xs" href="#">show all ' + exhibitCount + ' exhibits</button>');
        }

        exhibitMediaObjects.forEach((element, i) => {
          if (i >= _this.exhibitToggleThreshold) {
            element.classList.remove('d-flex')
            element.hidden = true
          }
        });
        toggleButton.on('click.see-all-exhibits-button', function(e) {
          e.preventDefault();

          // We don't have good text for a toggle off link.
          // When we do we can remove this and update the text appropriately
          toggleButton.remove();
          exhibitMediaObjects.forEach((element, i) => {
            if (i >= _this.exhibitToggleThreshold) {
              if(!element.hidden) {
                // Will be used when we have a toggle closed link
                element.classList.remove('d-flex')
                element.hidden = true
              } else {
                element.classList.add('d-flex')
                element.hidden = true
              }
            }
          });
        });


        // Don't add the link if it's already there (back-button click)
        if (container.find(toggleButton).length === 0 ) {
          container.append(toggleButton);
        }
      }
    },

    createExhibitMediaObject: function(exhibit, parentNode) {
      const exhibitUrl = this.exhibitsUrl(exhibit.slug)
      const wrapper = document.createElement('div')
      wrapper.dataset.exhibitPanelTarget = 'exhibit'
      wrapper.className = 'd-flex mb-2'
      const subtitle = exhibit.subtitle || ''
      const body = `<div><div class="exhibit-heading"><h4><a href="${exhibitUrl}">${exhibit.title}</a></h4>${subtitle}</div></div>`

      if (exhibit.thumbnail_url) {
        wrapper.innerHTML = `<a href="${exhibitUrl}" tabindex="-1" aria-hidden="true">
          <img alt="" src="${exhibit.thumbnail_url}" class="me-3" />
        </a>${body}`
      } else {
        wrapper.innerHTML = body
      }

      // Exhibit link clicked, add a custom event
      wrapper.querySelectorAll('a').forEach((imageLink) => {
        imageLink.addEventListener('click', (_e) => {
          ga('send', 'event', 'Exhibit link', 'clicked', [exhibit.title, exhibit.subtitle].join(' '), {
            'transport': 'beacon'
          });
        })
      })

      parentNode.appendChild(wrapper)
    }
}

Blacklight.onLoad(function() {
  $('[data-behavior="exhibits-panel"]').each(function(i, element) {
    ExhibitsPanel.init($(element));
  })
});
