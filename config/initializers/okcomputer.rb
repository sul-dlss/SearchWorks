require 'okcomputer'

OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

class SearcherCheck < OkComputer::Check
  attr_reader :searcher
  def initialize(searcher)
    super()
    @searcher = searcher
  end


  def check
    search = searcher.new(HTTP, 'status-check', 1).search

    mark_message "#{searcher} found #{search.total.inspect} results"
  rescue => e
    mark_failure
    mark_message e.to_s
  end

end

Rails.application.config.after_initialize do
  OkComputer::Registry.register 'search_articles', SearcherCheck.new(QuickSearch::ArticleSearcher)
  OkComputer::Registry.register 'search_catalog', SearcherCheck.new(QuickSearch::CatalogSearcher)
  OkComputer::Registry.register 'search_lib_guides', SearcherCheck.new(QuickSearch::LibGuidesSearcher)
  OkComputer::Registry.register 'search_library_website', SearcherCheck.new(QuickSearch::LibraryWebsiteApiSearcher)

  OkComputer.make_optional(%w[search_articles search_catalog search_lib_guides search_library_website])
end
