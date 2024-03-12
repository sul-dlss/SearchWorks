# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestLinkHelper do
  include MarcMetadataFixtures

  let(:document) do
    SolrDocument.new(
      id: '1234',
      item_display_struct: [
        { barcode: 'barcode', library: 'library', effective_permanent_location_code: 'home-location', temporary_location_code: 'current-location', type: 'type', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse-shelfkey', callnumber: 'callnumber' }
      ]
    )
  end

  describe '#request_url' do
    it 'returns a url including the catkey' do
      link = request_url(document, library: 'library', location: 'location')
      expect(link).to match(/item_id=1234/)
    end

    it 'returns a url including the library' do
      link = request_url(document, library: 'library', location: 'location')
      expect(link).to match(/origin=library/)
    end

    it 'returns a url including the location' do
      link = request_url(document, library: 'library', location: 'location')
      expect(link).to match(/origin_location=location/)
    end

    it 'returns a url including any other provided parameters' do
      link = request_url(document, library: 'library', location: 'location', foo: 'bar')
      expect(link).to match(/foo=bar/)
    end
  end
end
