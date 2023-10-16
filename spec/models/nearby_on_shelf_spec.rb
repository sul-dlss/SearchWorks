# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NearbyOnShelf do
  subject(:service) { described_class.new(field:, search_service:) }

  let(:field) { 'shelfkey' }
  let(:blacklight_config) { BrowseController.blacklight_config }
  let(:search_service) { Blacklight::SearchService.new(config: blacklight_config, search_state:) }
  let(:search_state) { Blacklight::SearchState.new({}, blacklight_config, context) }
  let(:context) { instance_double(BrowseController, controller_name: 'browse', action_name: 'index') }
  let(:repository) { instance_double(Blacklight::Solr::Repository) }

  let(:document_response) do
    instance_double(Blacklight::Solr::Response, grouped?: false, documents:)
  end
  let(:documents) do
    [
      SolrDocument.new(id: '1', title_sort: '', pub_date: '', item_display_struct: [{ barcode: '000', shelfkey: 'A' }, { barcode: '001', shelfkey: 'A' }]),
      SolrDocument.new(id: '3', title_sort: '', pub_date: '', item_display_struct: [{ barcode: '002', shelfkey: 'C' }]),
      SolrDocument.new(id: '2', title_sort: '', pub_date: '', item_display_struct: [{ barcode: '003', shelfkey: 'NOT_RELATED' }, { barcode: '004', shelfkey: 'B' }])
    ]
  end

  let(:terms_response) do
    { terms: { field => { 'A' => 1, 'B' => 2, 'C' => 3 } } }.with_indifferent_access
  end

  before do
    allow(blacklight_config).to receive(:repository).and_return(repository)
    allow(repository).to receive(:send_and_receive).with('alphaTerms', hash_including('terms.fl' => field)).and_return(terms_response)
    allow(repository).to receive(:search).and_return(document_response)
  end

  describe '#items' do
    it 'grabs the next set of terms from Solr' do
      service.items('A', incl: true, per: 3)

      expect(repository).to have_received(:send_and_receive).with('alphaTerms', hash_including('terms.fl' => 'shelfkey', 'terms.lower' => 'A', 'terms.limit' => 3))
    end

    it 'queries solr to get the documents that contain the next call numbers' do
      service.items('A', incl: true, per: 3)

      expect(repository).to have_received(:search).with(have_attributes(to_h: hash_including('q' => '{!lucene}shelfkey:(A OR B OR C)')))
    end

    it 'de-dupes shelfkeys + documents' do
      expect(service.items('A', incl: true, per: 3)).to have_attributes(length: 3)
    end

    it 'excludes call numbers that are not in the terms response' do
      expect(service.items('A', incl: true, per: 3)).not_to include(have_attributes(shelfkey: 'NOT_RELATED'))
    end

    it 'resorts the documents by their callnumber' do
      expect(service.items('A', incl: true, per: 3).map(&:shelfkey)).to eq %w[A B C]
    end

    it 'set the preferred callnumber on the document so it can be used in the view' do
      expect(service.items('A', incl: true, per: 3).map(&:document).map(&:preferred_item).map(&:shelfkey)).to eq %w[A B C]
    end
  end
end
