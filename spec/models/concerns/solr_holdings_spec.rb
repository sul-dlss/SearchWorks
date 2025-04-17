# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrHoldings do
  let(:document) { SolrDocument.new }

  it "provides a holdings method" do
    expect(document).to respond_to(:holdings)
    expect(document.holdings).to be_a Holdings
  end

  describe '#bound_with_folio_items' do
    let(:document) {
      SolrDocument.new(holdings_json_struct: [{ 'holdings' => [
        {
          'id' => '123456', 'holdingsType' => { 'code' => 'Bound-with' },
          'location' => {
            'effectiveLocation' => {
              'id' => "158168a3-ede4-4cc1-8c98-61f4feeb22ea",
              'code' => "SAL3-SEE-OTHER",
              'name' => "Off-campus storage",
              'campus' => { id: "c365047a-51f2-45ce-8601-e421ca3615c5", code: "SUL", name: "Stanford Libraries" },
              "details" => nil,
              "library" => { id: "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9", code: "SAL3", name: "Stanford Auxiliary Library 3" },
              "isActive" => true,
              "institution" => { id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", code: "SU", name: "Stanford University" }
            }
          },
          'boundWith' => {
            "item" => { id: '1234580', 'status' => 'avaliable', 'typeId' => 'typeId', 'typeName' => 'typeName',
                        'callNumber' => 'callNumber',
                        'location' => {
                          'effectiveLocation' => {
                            'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e', 'code' => "GREEN", 'name' => 'Green Library',
                            'campus' => { id: "c365047a-51f2-45ce-8601-e421ca3615c5", code: "SUL", name: "Stanford Libraries" },
                            "institution" => { id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", code: "SU", name: "Stanford University" },
                            "library" => { id: "f6b5519e-88d9-413e-924d-9ed96255f72e", code: "GREEN", name: "Green Library" }
                          }
                        } },
            "holding" => {}, "instance" => "instance"
          }
        }
      ] }])
    }

    it 'adds the boundWith data to bound_with_folio_items' do
      expect(document.bound_with_folio_items.first.id).to eq '1234580'
    end

    it 'populates effective_location with the items effective_location' do
      expect(document.bound_with_folio_items.first.effective_location.code).to eq 'GREEN'
    end

    it 'populates permanent_location with the holdings effective_location' do
      expect(document.bound_with_folio_items.first.permanent_location.code).to eq 'SAL3-SEE-OTHER'
    end
  end

  describe '#preferred_barcode' do
    let(:preferred) {
      SolrDocument.new(
        preferred_barcode: '12345',
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }
    let(:bad_preferred) {
      SolrDocument.new(
        preferred_barcode: 'does-not-exist',
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }
    let(:no_preferred) {
      SolrDocument.new(
        item_display_struct: [
          { barcode: '54321', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber1', full_shelfkey: '1' },
          { barcode: '12345', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'callnumber2', full_shelfkey: '2' }
        ]
      )
    }

    it 'returns the item based on preferred barcode' do
      expect(preferred.preferred_item.barcode).to eq '12345'
    end
    it 'returns the first item when the preferred barcode does not exist in the holdings' do
      expect(bad_preferred.preferred_item.barcode).to eq '54321'
    end
    it 'returns the first item if there is no preferred barcode available' do
      expect(no_preferred.preferred_item.barcode).to eq '54321'
    end
  end
end
