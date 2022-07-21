require 'spec_helper'

describe RequestLinkHelper do
  include MarcMetadataFixtures

  let(:document) do
    SolrDocument.new(
      id: '1234',
      item_display: ['barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber']
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
