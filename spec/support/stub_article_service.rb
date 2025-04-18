# frozen_string_literal: true

##
# Module included for RSpec tests to stub the article search service
module StubArticleService
  SAMPLE_RESULTS = [
    SolrDocument.new(
      id: 'abc123',
      eds_title: 'The title of the document',
      eds_subjects: '<searchLink fieldCode="SU" term="Kittens">Kittens</searchLink>' \
                    '<br/>' \
                    '<searchLink fieldCode="SU" term="Felines">Felines</searchLink>' \
                    '<br/>' \
                    '<searchLink fieldCode="SU" term="Companions">Companions</searchLink>',
      eds_html_fulltext_available: true
    ),
    SolrDocument.new(
      id: '321cba',
      eds_title: 'Another title for the document',
      eds_html_fulltext_available: true,
      eds_fulltext_links: [{
        'label' => 'HTML full text',
        'url' => 'http://example.com',
        'type' => 'customlink-fulltext'
      }]
    ),
    SolrDocument.new(
      id: 'wq/oeif.zzz',
      eds_title: 'Yet another title for the document',
      eds_fulltext_links: [{
        'label' => 'View request options',
        'url' => 'http://example.com',
        'type' => 'customlink-fulltext'
      }]
    ),
    SolrDocument.new(
      id: 'pdfyyy',
      eds_title: 'Another title for the document',
      eds_html_fulltext_available: true,
      eds_fulltext_links: [{ 'label' => 'PDF full text', 'url' => 'detail', 'type' => 'pdf' }]
    )
  ]

  def available_search_criteria
    {
      'AvailableLimiters' => [
        { 'Type' => 'select', 'Id' => 'RT', 'Label' => 'Limiter1' },
        { 'Type' => 'select', 'Id' => 'FT1', 'Label' => 'Limiter2', 'DefaultOn' => 'y' }
      ]
    }
  end

  def stub_article_service(type: :multiple, docs:)
    raise 'Article search service stubbed without any documents.' unless docs

    allow_any_instance_of(Eds::Session).to receive_messages(
      info: double(available_search_criteria:),
      session_token: 'abc123'
    )

    case type
    when :multiple
      allow_any_instance_of(Eds::Repository).to receive(:search).and_return(
        StubArticleResponse.new(docs)
      )
      allow_any_instance_of(Eds::Repository).to receive(:find_by_ids).and_return(
        StubArticleResponse.new(docs)
      )
    when :single
      raise "Single document response requsted but #{docs.length} provided." if docs.many?

      allow_any_instance_of(Eds::Repository).to receive(:find).and_return(
        StubArticleResponse.new([docs.first])
      )
      allow_any_instance_of(Eds::Repository).to receive(:find_by_ids).and_return(
        StubArticleResponse.new([docs.first])
      )
    when :error
      allow_any_instance_of(Eds::Repository).to receive(:search).and_raise(EBSCO::EDS::BadRequest)
    else
      raise "Unknown article stub type #{type} provided."
    end
  end

  class StubArticleResponse < Blacklight::Solr::Response # rubocop:disable Metrics/ClassLength
    attr_reader :documents
    delegate :empty?, to: :documents

    def initialize(documents)
      @documents = documents
      super({ date_range: { minyear: '1501', maxyear: '2018' } }, {})
    end

    def response
      { numFound: documents.count }
    end

    def facet_counts # rubocop:disable Metrics/MethodLength
      {
        'facet_fields' => {
          'pub_year_tisim' => ['2001', 1, '2002', 1],
          'eds_publication_type_facet' => ['Academic journals', 1],
          'eds_content_provider_facet' => ['Journal provider', 1],
          'eds_language_facet' => [
            "english",
            "477586",
            "undetermined",
            "69627",
            "russian",
            "5035",
            "japanese",
            "4179",
            "chinese",
            "3128",
            "german",
            "3092",
            "french",
            "3091",
            "spanish; castilian",
            "1976",
            "portuguese",
            "1593",
            "italian",
            "886",
            "korean",
            "884",
            "spanish",
            "668",
            "swedish",
            "611",
            "no linguistic content; not applicable",
            "601",
            "other",
            "550",
            "czech",
            "527",
            "turkish",
            "379",
            "polish",
            "377",
            "한국어",
            "298",
            "繁體中文",
            "191",
            "英文",
            "164",
            "multiple languages",
            "116",
            "ukrainian",
            "112",
            "dutch; flemish",
            "110",
            "austronesian languages",
            "95",
            "arabic",
            "94",
            "latin",
            "83",
            "hungarian",
            "79",
            "indonesian",
            "79",
            "croatian",
            "74",
            "slovenian",
            "66",
            "persian",
            "58",
            "eng",
            "57",
            "romanian; moldavian; moldovan",
            "55",
            "hebrew",
            "54",
            "afrikaans",
            "52",
            "dutch",
            "46",
            "lithuanian",
            "44",
            "greek, ancient (to 1453)",
            "42"
          ]
        }
      }
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
