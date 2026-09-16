# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchworksMcp::Availability do
  describe '.fetch' do
    let(:request_attributes) { { allowed_request_types: ['Hold'], folio_status: 'Checked out' } }
    let(:item) do
      instance_double(
        Holdings::Item,
        live_lookup_item_id: 'item-1', folio_item?: true,
        effective_location: instance_double(Folio::Location, details: {}),
        permanent_location: instance_double(Folio::Location, id: 'location-uuid', cached_location_data: {}),
        library: 'SAL3', **request_attributes,
        effective_permanent_location_code: 'SAL3-STACKS', barcode: '36105000000000'
      )
    end
    let(:location) do
      instance_double(Holdings::Location, code: 'SAL3-STACKS', name: 'Stacks', items: [item])
    end
    let(:library) do
      instance_double(
        Holdings::Library, code: 'SAL3', name: 'Stanford Auxiliary Library 3', locations: [location]
      )
    end
    let(:holdings) { instance_double(Holdings, items: [item], libraries: [library]) }
    let(:online_link) do
      instance_double(
        Links::Link, href: 'https://purl.fdlp.gov/GPO/LPS59339', link_text: 'purl.fdlp.gov', stanford_only?: false
      )
    end
    let(:document) { instance_double(SolrDocument, id: '123', holdings:, preferred_online_links: [online_link]) }
    let(:search_service) { instance_double(Blacklight::SearchService, fetch: document) }
    let(:live_lookup) do
      instance_double(
        LiveLookup,
        records: [
          {
            item_id: 'item-1', due_date: '09/30/2026', status: 'Checked out',
            is_available: false, is_requestable_status: true
          }
        ]
      )
    end

    before do
      allow(document).to receive(:[]).with(:uuid_ssi).and_return('instance-uuid')
      allow(described_class).to receive(:search_service).and_return(search_service)
      allow(LiveLookup).to receive(:new).with('instance-uuid').and_return(live_lookup)
    end

    it 'returns live availability, request links, and online sources' do
      result = described_class.fetch(id: '123')

      expect(result[:structured_content]).to include(
        id: '123',
        url: 'https://searchworks.stanford.edu/view/123',
        availability: [include(
          item_id: 'item-1', status: 'Checked out', is_available: false,
          library: 'Stanford Auxiliary Library 3', library_code: 'SAL3',
          location: 'Stacks', location_code: 'SAL3-STACKS',
          request_url: 'https://host.example.com/requests/new?barcode=36105000000000&item_id=123&origin=SAL3&origin_location=SAL3-STACKS'
        )],
        online_sources: [{ url: 'https://purl.fdlp.gov/GPO/LPS59339', label: 'purl.fdlp.gov', stanford_only: false }]
      )
      expect(result[:text]).to include(
        'item-1: Checked out — Stanford Auxiliary Library 3, Stacks',
        'Request: https://host.example.com/requests/new',
        'purl.fdlp.gov: https://purl.fdlp.gov/GPO/LPS59339'
      )
    end

    context 'when the location is pageable' do
      let(:request_attributes) { { allowed_request_types: ['Page'], folio_status: 'Available' } }

      it 'returns the location-level request URL shown by the web application' do
        request_url = described_class.fetch(id: '123').dig(:structured_content, :availability, 0, :request_url)

        expect(request_url).to eq(
          'https://host.example.com/requests/new?item_id=123&origin=SAL3&origin_location=SAL3-STACKS'
        )
      end
    end

    context 'when the record has no physical items' do
      let(:live_lookup) { instance_double(LiveLookup, records: []) }

      it 'still returns the online source' do
        result = described_class.fetch(id: '123')

        expect(result.dig(:structured_content, :online_sources, 0, :url)).to eq('https://purl.fdlp.gov/GPO/LPS59339')
        expect(result[:text]).to include('purl.fdlp.gov: https://purl.fdlp.gov/GPO/LPS59339')
      end
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
