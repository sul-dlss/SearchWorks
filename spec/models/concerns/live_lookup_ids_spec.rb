require 'spec_helper'

describe LiveLookupIds do
  let(:holdings_json_struct) do
    <<~JSON
      {
        "holdings": [{}],
        "items": [{
          "id": "3b1135cb-696d-57df-b0f2-4b7c586f8a09",
          "barcode": "36105114270999"}]
      }
    JSON
  end
  let(:document) do
    SolrDocument.new(
      id: '11111',
      uuid_ssi: 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f',
      item_display: ['36105114270999 -|- GREEN -|- STACKS -|-  -|-  -|-  -|-  -|-  -|-  -|-  -|-  -|-  '],
      holdings_json_struct: [holdings_json_struct]
    )
  end

  context 'FOLIO live lookup is enabled' do
    before { Settings.FOLIO_LIVE_LOOKUP = true }
    after { Settings.FOLIO_LIVE_LOOKUP = false }

    describe '#live_lookup_id' do
      it 'returns the instance record uuid' do
        expect(document.live_lookup_id).to eq 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f'
      end
    end

    describe '#barcode_to_uuid_mapping' do
      it 'returns a mapping between the item barcode and its uuid' do
        expect(document.barcode_to_uuid_mapping).to eq({ '36105114270999' => '3b1135cb-696d-57df-b0f2-4b7c586f8a09' })
      end
    end
  end

  context 'FOLIO live lookup is not enabled' do
    before { Settings.FOLIO_LIVE_LOOKUP = false }

    describe '#live_lookup_id' do
      it 'returns the bib record id' do
        expect(document.live_lookup_id).to eq '11111'
      end
    end

    describe '#barcode_to_uuid_mapping' do
      it { expect(document.barcode_to_uuid_mapping).to be_empty }
    end
  end
end
