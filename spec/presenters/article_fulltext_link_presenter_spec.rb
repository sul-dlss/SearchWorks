# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleFulltextLinkPresenter do
  let(:context) do
    controller = ArticlesController.new
    controller.request = ActionController::TestRequest.create(controller.class)
    controller.request.path_parameters[:format] = Mime[format]
    controller.view_context
  end

  let(:format) { :json }

  let(:document) { EdsDocument.new }

  subject(:presenter) { described_class.new(document:, context:) }

  describe '#links' do
    subject(:links) { presenter.links }

    let(:link) { links.first }
    let(:page) { Capybara.string(link) }

    context 'when the document does not have links' do
      it { is_expected.to be_empty }
    end

    context 'when the document has link' do
      let(:document) do
        EdsDocument.new(
          'eds_fulltext_links' => [
            { 'label' => 'Check SFX for full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }
          ]
        )
      end

      it 'includes a rendered link representing that data' do
        expect(links.length).to eq 1

        expect(page).to have_css('span.online-label', text: 'Full text')
        expect(page).to have_link('View on content provider\'s site', href: 'http://example.com')
      end
    end

    context 'when the document has a stanford-only link' do
      let(:document) do
        EdsDocument.new(
          'id' => '00001',
          'eds_fulltext_links' => [
            { 'url' => 'detail', 'label' => 'PDF Full Text', 'type' => 'pdf' }
          ]
        )
      end

      context 'when format is json' do
        it 'includes a span with stanford-only class' do
          expect(page).to have_css 'span.online-label', text: 'Full text'
          expect(page).to have_link 'View/download PDF'
          expect(page).to have_css 'span.stanford-only'
        end
      end

      context 'when format is html' do
        let(:format) { :html }

        it 'includes the svg icon' do
          expect(page).to have_css 'span.online-label', text: 'Full text'
          expect(page).to have_link 'View/download PDF'
          expect(page).to have_css 'span[aria-label="Stanford-only"] svg'
        end
      end
    end

    context 'when the document does not have a link but does include full-text' do
      let(:document) { EdsDocument.new(id: 'abc123', 'eds_html_fulltext_available' => true) }

      it 'includes a link to the document to view the full text' do
        expect(links.length).to eq 1

        expect(page).to have_css('span.online-label', text: 'Full text')
        expect(page).to have_link('View on detail page', href: 'http://test.host/articles/abc123')
      end
    end
  end
end
