# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JsonResultsDocumentPresenter do
  subject(:presenter) { described_class.new(source_document) }

  let(:document_data) { { id: 'abc123', title_display: 'The Title' } }
  let(:source_document) { SolrDocument.new(document_data) }

  describe '#as_json' do
    it 'returns the SolrDocument as_json response' do
      expect(presenter.as_json).to eq({ 'id' => 'abc123', 'title_display' => 'The Title' })
    end

    context 'when the source document is available online' do
      before do
        document_data['url_sfx'] = 'https://example.com'
      end

      it 'includes the fulltext_link_html field' do
        expect(presenter.as_json['fulltext_link_html'].length).to eq 1
        expect(presenter.as_json['fulltext_link_html'].first).to match(/<a href=.*example.com.*>Find full text<\/a>/)
      end
    end

    context 'when the source document is available online to only Stanford users' do
      before do
        document_data['marc_links_struct'] = [{
          "html": "<a href='https://example.com'>The Link</a> ",
          "fulltext": true,
          "stanford_only": true
        }]
      end

      it 'includes the link wrapped in a span with a class to be styled by consumers' do
        expect(presenter.as_json['fulltext_link_html'].length).to eq 1
        expect(presenter.as_json['fulltext_link_html'].first).to include('<span class="stanford-only">')
        expect(presenter.as_json['fulltext_link_html'].first).to match(/<a href=.*example.com.*>The Link<\/a>/)
      end
    end

    context 'when a document is available via temporary access' do
      before do
        document_data['ht_htid_ssim'] = '123456'
      end

      it 'includes the temporary_access_link_html field with appropriate data' do
        expect(presenter.as_json['temporary_access_link_html'].length).to eq 1
        expect(presenter.as_json['temporary_access_link_html'].first).to include('<span class="stanford-only">')
        expect(presenter.as_json['temporary_access_link_html'].first).to match(/<a href=.*babel.hathitrust.org.*<\/a>/)
      end
    end
  end
end
