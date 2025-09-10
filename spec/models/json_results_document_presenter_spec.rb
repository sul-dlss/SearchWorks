# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonResultsDocumentPresenter do
  subject(:presenter) { described_class.new(source_document) }

  let(:document_data) { { id: 'abc123', title_display: 'The Title' } }
  let(:source_document) { SolrDocument.new(document_data) }

  describe '#as_json' do
    it 'returns the SolrDocument as_json response' do
      expect(presenter.as_json).to eq({ 'id' => 'abc123', 'title_display' => 'The Title' })
    end

    context 'when the source document is available online to only Stanford users' do
      before do
        document_data['marc_links_struct'] = [{
          "href": "https://sciendo.com",
          "link_text": "The Link",
          "fulltext": true,
          "stanford_only": true
        }]
      end

      let(:json) { presenter.as_json.with_indifferent_access }

      it 'includes the link wrapped in a span with a class to be styled by consumers and uses EzProxy for the link' do
        expect(json['links'].first).to include(href: 'https://stanford.idm.oclc.org/login?qurl=https%3A%2F%2Fsciendo.com', link_text: 'The Link', stanford_only: true)
      end
    end
  end
end
