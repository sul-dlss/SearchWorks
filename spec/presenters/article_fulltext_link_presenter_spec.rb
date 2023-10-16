# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleFulltextLinkPresenter do
  let(:context) do
    Class.new do
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::UrlHelper

      # mapping this to path for tests so
      # we don't have to provide a host
      def article_url(args)
        article_path(args)
      end
    end.new
  end

  let(:document) { SolrDocument.new }

  subject(:presenter) { described_class.new(document:, context:) }

  describe '#links' do
    context 'when the document does not have links' do
      it 'is an empty array' do
        expect(presenter.links).to eq([])
      end
    end

    context 'when the document has link' do
      let(:document) do
        SolrDocument.new(
          'eds_fulltext_links' => [
            { 'label' => 'Check SFX for full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }
          ]
        )
      end

      it 'includes a rendered link representing that data' do
        expect(presenter.links.length).to eq 1
        link = Capybara.string(presenter.links.first)

        expect(link).to have_css('span.online-label', text: 'Full text')
        expect(link).to have_link('View on content provider\'s site', href: 'http://example.com')
      end
    end

    context 'when the document has a stanford-only link' do
      let(:document) do
        SolrDocument.new(
          'id' => '00001',
          'eds_fulltext_links' => [
            { 'url' => 'detail', 'label' => 'PDF Full Text', 'type' => 'pdf' }
          ]
        )
      end

      before do
        allow(presenter).to receive(:article_fulltext_link_url).and_return('http://example.com')
        allow(presenter).to receive(:image_url)
        allow(presenter).to receive(:image_tag)
      end

      it 'includes a span with stanford-only class' do
        expect(Capybara.string(presenter.links.first)).to have_css('span.stanford-only')
      end
    end

    context 'when the document does not have a link but does include full-text' do
      let(:document) { SolrDocument.new(id: 'abc123', 'eds_html_fulltext_available' => true) }

      it 'includes a link to the document to view the full text' do
        expect(presenter.links.length).to eq 1
        link = Capybara.string(presenter.links.first)

        expect(link).to have_css('span.online-label', text: 'Full text')
        expect(link).to have_link('View on detail page', href: '/articles/abc123')
      end
    end
  end
end
