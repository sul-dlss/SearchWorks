# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'JSON API Responses' do
  describe 'from catalog' do
    it 'has augmmented documents using the JsonResultsDocumentPresenter' do
      get '/catalog', params: { q: '57', format: 'json' }
      documents = response.parsed_body.dig('response', 'docs')

      expect(documents.length).to be 2
      expect(documents.first['fulltext_link_html']).to be_present
      expect(documents.first['fulltext_link_html'].first).to include('sfx.example.com')
    end
  end

  describe 'from articles' do
    before do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      get articles_path(q: 'kittens', format: 'json')
    end

    let(:docs) { response.parsed_body.dig('response', 'docs') }

    it 'includes the fulltext_link_html data' do
      expect(Capybara.string(docs[0]['fulltext_link_html'])).to have_link('View on detail page')
      expect(docs[0]['link']).to eq({ "full_text" => true, "html" => "<a href=\"http://www.example.com/articles/abc123\">View on detail page</a>", "stanford_only" => false, "pdf" => false })
      expect(Capybara.string(docs[1]['fulltext_link_html'])).to have_link('View full text')
      expect(docs[1]['link']).to eq({ "full_text" => true, "html" => "<a href=\"http://example.com\">View full text</a>", "stanford_only" => false, "pdf" => false })

      expect(
        Capybara.string(docs[2]['fulltext_link_html'])
      ).to have_link('Find full text or request')
      expect(docs[2]['link']).to eq({ "full_text" => false, "html" => "<a href=\"http://example.com\">Find full text or request</a>", "stanford_only" => false, "pdf" => false })

      expect(Capybara.string(docs[3]['fulltext_link_html'])).to have_link('View/download PDF')
      expect(docs[3]['link']).to eq({ "full_text" => true,
                                      "html" => "<a href=\"http://www.example.com/articles/pdfyyy/pdf/fulltext\">View/download PDF</a>",
                                      "stanford_only" => true,
                                      "pdf" => true })
    end
  end
end
