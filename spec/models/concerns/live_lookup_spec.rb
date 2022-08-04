require 'spec_helper'

RSpec.describe LiveLookup do
  let(:document) do
    SolrDocument.new(
      'id' => '893965',
      'uuid_ssi' => '9af85395-3104-5fc9-88ab-15554765c2d2',
      'holdings_json_struct' => [holdings_json_struct.to_json]
    )
  end

  let(:holdings_json_struct) do
    { 'holdings' =>
      [],
      'items' =>
      [{ 'id' => 'aec715cd-4fd1-535a-975b-adf53c211800',
         'barcode' => '36105036505977' }] }
  end

  context 'FOLIO_LIVE_LOOKUP is enabled' do
    before do
      Settings.FOLIO_LIVE_LOOKUP = true
    end

    describe '#live_lookup_id' do
      it 'returns the UUID for the instance' do
        expect(document.live_lookup_id).to eq '9af85395-3104-5fc9-88ab-15554765c2d2'
      end
    end

    describe '#barcodes_uuids' do
      it 'returns a mapping between barcodes and item UUIDs filtering out any that are missing' do
        expect(document.barcodes_uuids).to eq({ '36105036505977' => 'aec715cd-4fd1-535a-975b-adf53c211800' })
      end
    end
  end

  context 'FOLIO_LIVE_LOOKUP is not enabled' do
    before do
      Settings.FOLIO_LIVE_LOOKUP = false
    end

    describe '#live_lookup_id' do
      it 'returns the catalog key for the record' do
        expect(document.live_lookup_id).to eq '893965'
      end
    end

    describe '#barcodes_uuids' do
      it 'returns an empty hash' do
        expect(document.barcodes_uuids).to be_empty
      end
    end
  end
end
