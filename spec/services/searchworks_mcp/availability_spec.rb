# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::Availability do
  describe '.fetch' do
    it 'looks up the catalog document and returns its live availability records' do
      item = instance_double(
        Holdings::Item,
        live_lookup_item_id: 'item-1', folio_item?: true, allowed_request_types: ['Hold'],
        library: 'SAL3', effective_permanent_location_code: 'SAL3-STACKS', barcode: '36105000000000'
      )
      holdings = instance_double(Holdings, items: [item])
      document = instance_double(SolrDocument, id: '123', holdings:)
      search_service = instance_double(Blacklight::SearchService, fetch: document)
      live_lookup = instance_double(
        LiveLookup,
        records: [
          {
            item_id: 'item-1', due_date: '09/30/2026', status: 'Checked out',
            is_available: false, is_requestable_status: true
          }
        ]
      )
      allow(document).to receive(:[]).with(:uuid_ssi).and_return('instance-uuid')
      allow(described_class).to receive(:search_service).and_return(search_service)
      allow(LiveLookup).to receive(:new).with('instance-uuid').and_return(live_lookup)

      result = described_class.fetch(id: '123')

      expect(result[:structured_content]).to include(
        id: '123',
        url: 'https://searchworks.stanford.edu/view/123',
        availability: [include(
          item_id: 'item-1', status: 'Checked out', is_available: false,
          request_url: 'https://host.example.com/requests/new?barcode=36105000000000&item_id=123&origin=SAL3&origin_location=SAL3-STACKS'
        )]
      )
      expect(result[:text]).to include('item-1: Checked out', 'Request: https://host.example.com/requests/new')
    end

    it 'returns a model-visible error when availability cannot be retrieved' do
      allow(described_class).to receive(:search_service).and_raise(StandardError, 'private backend details')
      allow(SearchworksMcp).to receive(:report_exception)

      result = described_class.fetch(id: '123')

      expect(result).to include(error: true)
      expect(result[:text]).to eq('Availability information is temporarily unavailable.')
      expect(result.to_json).not_to include('private backend details')
    end
  end
end
