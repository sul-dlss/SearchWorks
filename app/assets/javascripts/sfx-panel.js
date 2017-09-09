/*
  JavaScript module to fetch SFX Content into the SFX panel.
 */

var SfxPanel = (function() {
  var panelSelector = '[data-behavior="sfx-panel"]';
  var panelBodySelector = '[data-behavior="sfx-panel-body"]';

  function getSfxData(url) {
    $.ajax(url).done(function(data){
      updatePanelBody(data);
      $sfxPanel().show();
    }).fail(function(){
      updatePanelBody('Unable to connect to SFX');
    });
  }

  function updatePanelBody(content) {
    $sfxPanelBody().html(content);
  }

  function $sfxPanel() {
    return $(panelSelector);
  }

  function $sfxPanelBody() {
    return $(panelBodySelector);
  }

  return {
    init: function() {
      if($sfxPanel().length > 0) {
        var dataUrl = $sfxPanel().data('sfx-url');

        if(dataUrl !== undefined) {
          getSfxData(dataUrl);
        }
      }
    }
  };

}());

Blacklight.onLoad(function() {
  SfxPanel.init();
});
