# frozen_string_literal: true

##
# Module included for RSpec tests to stub the article search service
module StubArticleService # rubocop:disable Metrics/ModuleLength
  def self.full_text_document
    EdsDocument.new(
      {
        'id' => 'abc123',
        'RecordInfo' => {
          'BibRecord' => {
            'BibEntity' => {
              'Titles' => [
                { 'Type' => 'main', 'TitleFull' => 'The title of the document' }
              ]
            }
          }
        },
        "Items" => [
          {
            "Data" => '<searchLink fieldCode="SU" term="Kittens">Kittens</searchLink>' \
                      '<br/>' \
                      '<searchLink fieldCode="SU" term="Felines">Felines</searchLink>' \
                      '<br/>' \
                      '<searchLink fieldCode="SU" term="Companions">Companions</searchLink>',
            "Group" => "Su",
            "Label" => "Subject Terms",
            "Name" => "Subject"
          }
        ],
        'FullText' => {
          'Text' => {
            'Availability' => '1'
          }
        }
      }
    )
  end

  def self.non_fulltext_document
    EdsDocument.new(
      {
        'id' => 'wq/oeif.zzz',
        'RecordInfo' => {
          'BibRecord' => {
            'BibEntity' => {
              'Titles' => [
                { 'Type' => 'main', 'TitleFull' => 'Yet another title for the document' }
              ]
            }
          }
        },
        'FullText' => {
          'CustomLinks' => [
            {
              'Text' => 'View request options',
              'Url' => 'http://example.com'
            }
          ]
        }
      }
    )
  end

  SAMPLE_RESULTS = [
    full_text_document,
    EdsDocument.new(
      {
        'id' => '321cba',
        'RecordInfo' => {
          'BibRecord' => {
            'BibEntity' => {
              'Titles' => [
                { 'Type' => 'main', 'TitleFull' => 'Another title for the document' }
              ]
            }
          }
        },
        'FullText' => {
          'CustomLinks' => [
            {
              'Text' => 'HTML full text',
              'Url' => 'http://example.com'
            }
          ],
          'Text' => {
            'Availability' => '1'
          }
        }
      }
    ),
    non_fulltext_document,
    EdsDocument.new(
      {
        'id' => 'pdfyyy',
        'RecordInfo' => {
          'BibRecord' => {
            'BibEntity' => {
              'Titles' => [
                { 'Type' => 'main', 'TitleFull' => 'Another title for the document' }
              ]
            }
          }
        },
        'FullText' => {
          'Links' => [
            {
              'Type' => 'pdflink'
            }
          ],
          'Text' => {
            'Availability' => '1'
          }
        }
      }
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
      info: { 'AvailableSearchCriteria' => available_search_criteria },
      session_token: 'abc123'
    )

    case type
    when :multiple
      allow_any_instance_of(Eds::Repository).to receive(:search).and_return(
        StubArticleResponse.new(docs)
      )
      allow_any_instance_of(Eds::Repository).to receive(:find_by_ids).and_return(
        docs
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
      allow_any_instance_of(Eds::Repository).to receive(:search).and_raise(Faraday::Error)
      allow_any_instance_of(Eds::Repository).to receive(:find).and_raise(Faraday::Error)

    else
      raise "Unknown article stub type #{type} provided."
    end
  end

  class StubArticleResponse < SimpleDelegator
    attr_reader :documents
    delegate :empty?, to: :documents

    def initialize(documents)
      @documents = documents
      @stub_eds_response = Eds::Response.new({
                                               'SearchResult' => {
                                                 'AvailableFacets' => self.class.stub_facet_counts,
                                                 'Statistics' => {
                                                   'TotalHits' => documents.count
                                                 }
                                               }
                                             }, Eds::SearchBuilder.new([], ArticlesController.new).with({}))
      super(@stub_eds_response)
    end

    def self.stub_facet_counts # rubocop:disable Metrics/MethodLength
      [
        {
          'Id' => 'SourceType',
          'AvailableFacetValues' => [
            { 'Value' => 'Academic journals', 'Count' => 1 }
          ]
        },
        {
          'Id' => 'Language',
          'AvailableFacetValues' => [
            { 'Value' => 'english', 'Count' => 477586 },
            { 'Value' => 'undetermined', 'Count' => 69627 },
            { 'Value' => 'russian', 'Count' => 5035 },
            { 'Value' => 'japanese', 'Count' => 4179 },
            { 'Value' => 'chinese', 'Count' => 3128 },
            { 'Value' => 'german', 'Count' => 3092 },
            { 'Value' => 'french', 'Count' => 3091 },
            { 'Value' => 'spanish; castilian', 'Count' => 1976 },
            { 'Value' => 'portuguese', 'Count' => 1593 },
            { 'Value' => 'italian', 'Count' => 886 },
            { 'Value' => 'korean', 'Count' => 884 },
            { 'Value' => 'spanish', 'Count' => 668 },
            { 'Value' => 'swedish', 'Count' => 611 },
            { 'Value' => 'no linguistic content; not applicable', 'Count' => 601 },
            { 'Value' => 'other', 'Count' => 550 },
            { 'Value' => 'czech', 'Count' => 527 },
            { 'Value' => 'turkish', 'Count' => 379 },
            { 'Value' => 'polish', 'Count' => 377 },
            { 'Value' => '한국어', 'Count' => 298 },
            { 'Value' => '繁體中文', 'Count' => 191 },
            { 'Value' => '英文', 'Count' => 164 },
            { 'Value' => 'multiple languages', 'Count' => 116 },
            { 'Value' => 'ukrainian', 'Count' => 112 },
            { 'Value' => 'dutch; flemish', 'Count' => 110 },
            { 'Value' => 'austronesian languages', 'Count' => 95 },
            { 'Value' => 'arabic', 'Count' => 94 },
            { 'Value' => 'latin', 'Count' => 83 },
            { 'Value' => 'hungarian', 'Count' => 79 },
            { 'Value' => 'indonesian', 'Count' => 79 },
            { 'Value' => 'croatian', 'Count' => 74 },
            { 'Value' => 'slovenian', 'Count' => 66 },
            { 'Value' => 'persian', 'Count' => 58 },
            { 'Value' => 'eng', 'Count' => 57 },
            { 'Value' => 'romanian; moldavian; moldovan', 'Count' => 55 },
            { 'Value' => 'hebrew', 'Count' => 54 },
            { 'Value' => 'afrikaans', 'Count' => 52 },
            { 'Value' => 'dutch', 'Count' => 46 },
            { 'Value' => 'lithuanian', 'Count' => 44 },
            { 'Value' => 'greek, ancient (to 1453)', 'Count' => 42 }
          ]
        }
      ]
    end
  end
end

RSpec.configure do |config|
  config.include StubArticleService
end
