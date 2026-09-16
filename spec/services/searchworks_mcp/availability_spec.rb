# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::Availability do
  describe '.fetch' do
    it 'looks up the catalog document and returns its live availability records' do
      document = SolrDocument.new(id: '123', uuid_ssi: 'instance-uuid')
      search_service = instance_double(Blacklight::SearchService, fetch: document)
      live_lookup = instance_double(
        LiveLookup,
        records: [
          {
            item_id: 'item-1', due_date: nil, status: 'Available',
            is_available: true, is_requestable_status: false
          }
        ]
      )
      allow(described_class).to receive(:search_service).and_return(search_service)
      allow(LiveLookup).to receive(:new).with('instance-uuid').and_return(live_lookup)

      result = described_class.fetch(id: '123')

      expect(result[:structured_content]).to include(
        id: '123',
        url: 'https://searchworks.stanford.edu/view/123',
        availability: [include(item_id: 'item-1', status: 'Available', is_available: true)]
      )
      expect(result[:text]).to include('item-1: Available')
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
