Blacklight.onLoad(function() {
  $(".document-thumbnail div[data-context-href], .item-thumb div[data-context-href]")
    .addClass('cursor-pointer')
    .on('click.search-context', Blacklight.handleSearchContextMethod);
});
