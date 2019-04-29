/**
 * This should probably not be in the global namespace.
*/
class WikiDataSparql {
  constructor(uriMap) {
    this.uriMap = uriMap;
  }

  wikiIdFromLocId(callback) {
    $.ajax({
      url: this.endpoint,
      headers: { Accept: 'application/sparql-results+json' },
      data: { query: this.queryForLoCID },
      format: 'jsonp',
      success: (data) => {
        if(!(data
              && data.results
              && data.results.bindings
              && data.results.bindings[0]
              && data.results.bindings[0].entity
              && data.results.bindings[0].entity.value
           )) return;

        if(typeof callback === 'function') {
          callback(data.results.bindings[0].entity.value);
        }
      },
    });
  }

  wikiDataFromWikiId(callback) {
    $.ajax({
      url: this.endpoint,
      headers: { Accept: 'application/sparql-results+json' },
      format: 'jsonp',
      data: { query: this.queryForEntityData },
      success: (data) => {
        if(!(data
              && data.results
              && data.results.bindings
        )) return;

        if(typeof callback === 'function') {
          callback(data.results.bindings);
        }
      },
    });
  }

  getAudioWikiData(callback) {
    $.ajax({
      url: this.endpoint,
      headers: { Accept: 'application/sparql-results+json' },
      format: 'jsonp',
      data: { query: this.queryForAudioData },
      success: (data) => {
        if(!(data
              && data.results
              && data.results.bindings
        )) return;

        if(typeof callback === 'function') {
          callback(data.results.bindings, this.uriMap.wid);
        }
      },
    });
  }

  get endpoint() {
    return 'https://query.wikidata.org/sparql?';
  }

  get queryForAudioData() {
    return `PREFIX entity: <http://www.wikidata.org/entity/>

    SELECT ?valUrl
    WHERE
    {
      hint:Query hint:optimizer 'None' .
      { BIND(entity:${this.uriMap.wid} AS ?valUrl) .
        FILTER (LANG(?val) = "en")
      }
      UNION
      { entity:${this.uriMap.wid} ?propUrl ?valUrl .
        ?property ?ref ?propUrl .
        ?property rdfs:label ?propLabel .
        FILTER (lang(?propLabel) = "en")
        FILTER (?propUrl = wdt:P51)
      }
    }`;
  }

  get queryForLoCID() {
    return `
    SELECT DISTINCT ?entity WHERE {
      { ?entity wdtn:P244 <${this.uriMap.loc && this.uriMap.loc[0]}> }
      UNION
      { ?entity wdtn:P214 <${this.uriMap.viaf && this.uriMap.viaf[0]}> }
      UNION
      { ?entity wdtn:P213 <${this.uriMap.isni && this.uriMap.isni[0]}> }
    }`;
  }

  get queryForEntityData() {
    return `PREFIX entity: <http://www.wikidata.org/entity/>

    SELECT ?propUrl ?propLabel ?valLabel ?valUrl ?type
    WHERE
    {
      hint:Query hint:optimizer 'None' .
      {	BIND(entity:${this.uriMap.wid} AS ?valUrl) .
        BIND("N/A" AS ?propUrl ) .
        BIND("Name"@en AS ?propLabel ) .
        BIND("N/A"@en AS ?type ) .
        entity:${this.uriMap.wid} rdfs:label ?valLabel .
        FILTER (LANG(?val) = "en")
      }
      UNION
      {	entity:${this.uriMap.wid} ?propUrl ?valUrl .
        ?property ?ref ?propUrl .
        ?property rdf:type wikibase:Property .
        ?property rdfs:label ?propLabel.
        FILTER (lang(?propLabel) = "en")
        FILTER isliteral(?valUrl)
        BIND(?valUrl AS ?valLabel)
    	}
      UNION
      {	entity:${this.uriMap.wid} ?propUrl ?valUrl .
        ?property ?ref ?propUrl .
        ?property rdf:type wikibase:Property .
        ?property rdfs:label ?propLabel.
        FILTER (lang(?propLabel) = "en")
        FILTER isIRI(?valUrl)
        ?valUrl rdfs:label ?valLabel
        FILTER (LANG(?valLabel) = "en")
        BIND('literal' AS ?type)
      }
      UNION
      {	entity:${this.uriMap.wid} ?propUrl ?valUrl .
        ?property ?ref ?propUrl .
        ?property rdf:type wikibase:Property .
        ?property rdfs:label ?propLabel.
        FILTER (lang(?propLabel) = "en")
        FILTER (?propUrl = wdt:P18 || ?propUrl = wdt:P154)
        BIND(?valUrl AS ?valLabel)
        BIND('image' AS ?type)
    	}
      UNION
      { entity:${this.uriMap.wid} schema:description ?valLabel .
        FILTER (lang(?valLabel) = "en")
        BIND('Description' AS ?propLabel)
        BIND('fake-desc-uri' AS ?propUrl)
      }
      UNION
      { entity:${this.uriMap.wid} rdfs:label ?valLabel .
        FILTER (lang(?valLabel) = "en")
        BIND('label' as ?type)
        BIND('Label' AS ?propLabel)
        BIND('fake-label-uri' AS ?propUrl)
      }
    }
    ORDER BY ?propLabel`;
  }
}

var AuthorityLookups = (function() {
  // Simple utility function to pull the identifier after the last slash
  function idFromURI(uri) {
    if(!uri) return;
    return /\/(\w+)$/.exec(uri)[1];
  }

  function $authorityLinks() {
    return $('[data-authority-uri]');
  }

  function $authorityToggles() {
    return $('[data-behavior="togglePanel"]');
  }

  function $autoOpenPanels () {
    return $('[data-wikidata-panel-autoopen]');
  }

  function groupStatements(statements) {
    var items = {};
    for(var index in statements) {
      var itemData = statements[index];
      if(items[itemData.propUrl.value]) {
        items[itemData.propUrl.value].values.push({
          uri: itemData.valUrl.value,
          value: itemData.valLabel.value
        });
      } else {
        items[itemData.propUrl.value] = {
          image: (itemData.type && itemData.type.value === 'image') && itemData.valLabel.value,
          label: itemData.propLabel.value,
          values: [{
            uri: itemData.valUrl && itemData.valUrl.value,
            value: itemData.valLabel.value
          }],
        };
      }
    }
    return items;
  }

  function uriObjectFromData(element) {
    var uriObject = {};
    if(element.data('loc-uris')) {
      uriObject['loc'] = element.data('loc-uris').split(',');
    }
    if(element.data('viaf-uris')) {
      uriObject['viaf'] = element.data('viaf-uris').split(',')
    }
    if(element.data('isni-uris')) {
      uriObject['loc'] = element.data('isni-uris').split(',')
    }
    return uriObject;
  }

  return {
    showTogglesForWikiDataEntities: function() {
      $authorityToggles().each(function() {
        var toggle = $(this);
        var uriMap = uriObjectFromData(toggle);
        new WikiDataSparql(uriMap).wikiIdFromLocId((entityUri) => {
          var wid = idFromURI(entityUri);
          if(!wid) return;

          toggle.next().data('wikidata-id', wid)
          toggle.show();
        });
      });
    },

    addClickBehavior: function() {
      var _this = this;
      $authorityToggles().each(function() {
        var $toggle = $(this);
        var $panel = $toggle.next();

        $toggle.on('click', function() {
          $toggle.toggleClass('fa-info-circle', !$toggle.hasClass('fa-info-circle'));
          $toggle.toggleClass('fa-times-circle', !$toggle.hasClass('fa-times-circle'));
          _this.fetchWikiData($panel);
          $panel.slideToggle();
        });
      });
    },

    fetchWikiData: function(panel, autoOpen = false) {
      if(panel.data('wikiDataFetched')) return;
      panel.data('wikiDataFetched', true);
      var _this = this;
      var wid = panel.data('wikidata-id');
      if(!wid) return;

      new WikiDataSparql({ wid: wid }).wikiDataFromWikiId((statements) => {
        var groupedStatements = groupStatements(statements);
        var $dl = $('<dl class="dl-horizontal"></dl>');
        if(autoOpen) {
          var $toggleButton = $('<i style="float: right;" class="fa fa-times-circle knowledge-panel-toggle"></i>');
          $toggleButton.on('click', function() {
            $toggleButton.toggleClass('fa-plus-circle', !$toggleButton.hasClass('fa-plus-circle'));
            $toggleButton.toggleClass('fa-times-circle', !$toggleButton.hasClass('fa-times-circle'));
            var parentPanel = $(this).parent('[data-wikidata-panel-autoopen]');
            panel.children().each(function() {
              if(!($(this).is($toggleButton) || $(this)[0].nodeName === 'H3')) {
                $(this).toggle();
              }
            });
          });
          panel.append($toggleButton)
        }

        if(groupedStatements['fake-label-uri']) {
          var $h3 = $(`<h3>${groupedStatements['fake-label-uri'].values[0].value}</h3>`);
          var dates = [];
          if(groupedStatements[_this.birthDatePropURI] || groupedStatements[_this.deathDatePropURI]) {
            var dates = [new Date(groupedStatements[_this.birthDatePropURI].values[0].value).getFullYear()];
            if(groupedStatements[_this.deathDatePropURI]) {
              dates.push(new Date(groupedStatements[_this.deathDatePropURI].values[0].value).getFullYear());
            } else {
              dates.push('');
            }
            $h3.append(` <span class="author-date">[${dates.join(' - ')}]</span>`);
          }
          panel.append($h3);
        }

        if(groupedStatements['fake-desc-uri']) {
          $dl.append(`<dt>${groupedStatements['fake-desc-uri'].label}</dt>`);
          for(i in groupedStatements['fake-desc-uri'].values) {
            $dl.append(`<dd>${groupedStatements['fake-desc-uri'].values[i].value}</dd>`);
          }
        }
        for(key in groupedStatements) {
          if(_this.propWhitelist.includes(key)) {
            $dl.append(`<dt>${groupedStatements[key].label}</dt>`);
            var $ul = $(`<ul data-behavior="knowledge-panel-truncate" class="${key && idFromURI(key)}"></ul>`);
            for(i in groupedStatements[key].values) {
              var propId = idFromURI(groupedStatements[key].values[i].uri);
              var $li = $(`<li id="${propId}">${groupedStatements[key].values[i].value}</li>`);
              $ul.append($li);
              if(propId && key === 'http://www.wikidata.org/prop/direct/P800') {
                new WikiDataSparql({ wid: propId }).getAudioWikiData((audioFiles, id) => {
                  for(i in audioFiles) {
                    $(`li#${id}`).append(
                      `<div><audio controls><source src="${audioFiles[i].valUrl.value}"></source></audio></div>`
                    );
                  }
                });
              }
            }

            $dl.append($('<dd></dd>').append($ul));
          }
        }

        var imageProp = groupedStatements[_this.imagePropURI] || groupedStatements[_this.logoPropURI];
        if(imageProp) {
          panel.append(`<img class="knowledge-panel-thumb" src="${imageProp.image}" />`)
        }
        panel.append($dl);
        panel.append(
          `<div class="knowledge-panel-footer">
            Sources: <a class="wikidata-source-link" href="https://wikidata.org/wiki/${wid}">
                      <span class="sr-only">editable source </span>Wikidata
                     </a>
            <div class="editable-source-help">Improve this knowledge panel by contributing to its open data source.</div>
          </div>`
        );

        $('[data-behavior="knowledge-panel-truncate"]').responsiveTruncate({ lines: 3, more: 'more...', less: 'less...' });
      });
    },

    fetchDataForAutoOpenPanels: function() {
      if(!$autoOpenPanels().length === 0) return;
      var _this = this;
      $autoOpenPanels().each(function() {
        var panel = $(this)
        var uriMap = uriObjectFromData(panel);
        new WikiDataSparql(uriMap).wikiIdFromLocId((entityUri) => {
          var wid = idFromURI(entityUri)
          if(!wid) return;
          panel.data('wikidata-id', wid);
          _this.fetchWikiData(panel, true);
          panel.show();
        });
      });
    },

    init: function() {
      this.fetchDataForAutoOpenPanels();
      this.showTogglesForWikiDataEntities();
      this.addClickBehavior();
    },

    birthDatePropURI: 'http://www.wikidata.org/prop/direct/P569',
    deathDatePropURI: 'http://www.wikidata.org/prop/direct/P570',
    imagePropURI: 'http://www.wikidata.org/prop/direct/P18',
    logoPropURI: 'http://www.wikidata.org/prop/direct/P154',
    propWhitelist: [
      'http://www.wikidata.org/prop/direct/P106', // Occupations
      'http://www.wikidata.org/prop/direct/P161', // Cast members
      'http://www.wikidata.org/prop/direct/P800', // Notable works
      'http://www.wikidata.org/prop/direct/P840', // Narrative location
      'http://www.wikidata.org/prop/direct/P921', // Main subject
      'http://www.wikidata.org/prop/direct/P1283', // Filmography
      'http://www.wikidata.org/prop/direct/P4969', // Derivative work
    ],
  };
}());

Blacklight.onLoad(function() {
  AuthorityLookups.init();
});
