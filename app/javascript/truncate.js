import Blacklight from 'blacklight-frontend'

Blacklight.onLoad(function(){
  const metadataTruncateElements = document.querySelectorAll("[data-behavior='metadata-truncate']");
  metadataTruncateElements.forEach(element => {
    element.responsiveTruncate({ lines: 2, more: 'more...', less: 'less...' });
  });

  const truncateResultsMetadataElements = document.querySelectorAll("[data-behavior='truncate-results-metadata-links']");
  truncateResultsMetadataElements.forEach(element => {
    element.responsiveTruncate({lines: 2, more: 'more...', less: 'less...'});
  });

  const truncateElements = document.querySelectorAll("[data-behavior='truncate']");
  truncateElements.forEach(element => {
    element.responsiveTruncate({height: 60});
  });
});
