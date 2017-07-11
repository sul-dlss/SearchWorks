##
# Module included for RSpec tests to stub the article search service
module StubArticleService
  SAMPLE_RESULTS = [
      SolrDocument.new(id: 'abc123', eds_title: 'The title of the document'),
      SolrDocument.new(id: '321cba', eds_title: 'Another title for the document'),
      SolrDocument.new(id: 'wqoeif', eds_title: 'Yet another title for the document')
  ]

  def stub_article_service(type: :multiple, docs:)
    raise 'Article search service stubbed without any documents.' if docs.blank?

    allow_any_instance_of(ArticleController).to receive(:setup_eds_session).and_return('abc123')
    case type
    when :multiple
      allow_any_instance_of(Eds::SearchService).to receive(:search_results).and_return(
        [StubArticleResponse.new(docs), nil]
      )
    when :single
      raise "Single document response requsted but #{docs.length} provided." if docs.many?
      expect_any_instance_of(Eds::SearchService).to receive(:fetch).and_return(
        [StubArticleResponse.new(docs.first), docs.first]
      )
    else
      raise "Unknown article stub type #{type} provided."
    end
  end

  class StubArticleResponse < Blacklight::Solr::Response
    attr_reader :documents
    delegate :empty?, to: :documents

    def initialize(documents)
      @documents = documents
    end

    def response
      { numFound: documents.count }
    end

    def limit_value
      0
    end

    def total_pages
      1
    end

    def current_page
      0
    end

    def start
      0
    end

    def rows
      documents.count
    end

    def sort
      'score desc'
    end
  end
end

RSpec.configure do |config|
  config.include StubArticleService
end
