require 'rails_helper'

RSpec.describe Holdings do
  let(:holdings) {
    Holdings.new(
      SolrDocument.new(item_display_struct: [{ barcode: '123', library: 'abc' }]).items
    )
  }
  let(:complex_holdings) {
    Holdings.new(
      SolrDocument.new(
        item_display_struct: [
          { barcode: 'barcode', library: 'library', home_location: 'home-location', temporary_location_code: 'current-location', type: 'type', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse-shelfkey', callnumber: 'callnumber', full_shelfkey: 'full-shelfkey', scheme: 'LC' },
          { barcode: 'barcode2', library: 'library2', home_location: 'home-location2', temporary_location_code: 'current-location2', type: 'type2', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey2', reverse_shelfkey: 'reverse-shelfkey2', callnumber: 'callnumber2', full_shelfkey: 'full-shelfkey2', scheme: 'INTERNET' }
        ]
      ).items
    )
  }
  let(:sortable_holdings) {
    Holdings.new(
      SolrDocument.new(
        item_display_struct: [
          { barcode: 'barcode', library: 'library', home_location: 'home-location', temporary_location_code: 'current-location', type: 'type', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse-shelfkey', callnumber: 'callnumber', full_shelfkey: '999' },
          { barcode: 'barcode2', library: 'library2', home_location: 'home-location2', temporary_location_code: 'current-location2', type: 'type2', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey2', reverse_shelfkey: 'reverse-shelfkey2', callnumber: 'callnumber2', full_shelfkey: '111' }
        ]
      ).items
    )
  }
  let(:no_holdings) { Holdings.new }

  describe "#present?" do
    it "is false if there are no holdings" do
      expect(no_holdings).not_to be_present
    end

    it "is true if there are items in a viewable library" do
      expect(complex_holdings).to be_present
    end
  end

  describe "#items" do
    it "should return an array of Holdings::Items" do
      holdings.items.each do |item|
        expect(item).to be_a Holdings::Item
      end
    end
    it "should return an empty array if there are no holdings" do
      expect(no_holdings.items).to eq []
    end
    it "should be sorted by the shelfkey" do
      expect(sortable_holdings.items.map(&:full_shelfkey)).to eq ['111', '999']
    end
  end

  describe "#libraries" do
    let(:libraries) {
      Holdings.new(
        SolrDocument.new(
          item_display_struct: [
            { barcode: 'barcode', library: 'library', home_location: 'home-location' },
            { barcode: 'barcode', library: 'library2', home_location: 'home-location' },
            { barcode: 'barcode', library: 'library', home_location: 'home-location' }
          ]
        ).items
      )
    }
    let(:sortable_libraries) {
      Holdings.new(
        SolrDocument.new(
          item_display_struct: [
            { barcode: 'barcode', library: 'SAL3', home_location: 'home-location' },
            { barcode: 'barcode', library: 'GREEN', home_location: 'home-location' },
            { barcode: 'barcode', library: 'MARINE-BIO', home_location: 'home-location' }
          ]
        ).items
      )
    }

    it "should group by library" do
      expect(libraries.libraries.length).to eq 2
    end
    it "should sort by library code when there is no translation" do
      expect(libraries.libraries.map(&:code)).to eq ['library', 'library2']
    end
    it "should sort Green first then the rest alpha" do
      expect(sortable_libraries.libraries.length).to eq 3
      expect(sortable_libraries.libraries.map(&:code)).to eq ['GREEN', 'MARINE-BIO', 'SAL3']
    end
  end

  describe "#browsable_items" do
    it "should collapse callnumbers on the truncated callnumber" do
      expect(complex_holdings.items.length).to eq 2
      expect(complex_holdings.browsable_items.length).to eq 1
    end
  end

  describe "#find_by_barcode" do
    let(:found) { complex_holdings.find_by_barcode('barcode2') }

    it "should return a single Holdings::Item" do
      expect(found).to be_a Holdings::Item
    end
    it "should be the correct item" do
      expect(found.barcode).to eq 'barcode2'
    end
    it "should return nil if the barcode is not found" do
      expect(complex_holdings.find_by_barcode('not-a-barcode')).to be_nil
    end
  end

  describe "mhld" do
    let(:holdings_doc) {
      SolrDocument.new(
        item_display_struct: [
          { barcode: 'barcode', library: 'GREEN', home_location: 'STACKS', temporary_location_code: 'current-location', type: 'type', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse-shelfkey', callnumber: 'callnumber' }
        ],
        mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
      )
    }
    let(:mhld_only_doc) {
      SolrDocument.new(
        mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
      )
    }

    it "should match up mhlds in locations with existing call numbers" do
      holdings = holdings_doc.holdings
      expect(holdings.libraries.length).to eq 1
      expect(holdings.libraries.first.code).to eq 'GREEN'
      expect(holdings.libraries.first.locations.length).to eq 1
      location = holdings.libraries.first.locations.first
      expect(location.code).to eq 'STACKS'
      expect(location.items.length).to eq 1
      expect(location.items.first).to be_a Holdings::Item
      expect(location.mhld.length).to eq 1
      expect(location.mhld.first).to be_a Holdings::MHLD
    end
    it "should include mhlds that don't belong to an existing library or location" do
      holdings = mhld_only_doc.holdings
      expect(holdings.libraries.length).to eq 1
      expect(holdings.libraries.first.code).to eq 'GREEN'
      expect(holdings.libraries.first.locations.length).to eq 1
      location = holdings.libraries.first.locations.first
      expect(location.code).to eq 'STACKS'
      expect(location.items).not_to be_present
      expect(location.mhld.length).to eq 1
      expect(location.mhld.first).to be_a Holdings::MHLD
    end
    it 'should return the appropriate json hash for library and location' do
      mhld = holdings_doc.holdings.as_json.first[:mhld]
      expect(mhld).to be_a Array
      expect(mhld.first).to be_a Hash
      expect(mhld.first[:library]).to eq 'GREEN'
      expect(mhld.first[:location]).to eq 'STACKS'
      expect(holdings_doc.holdings.as_json.first[:locations].first[:mhld]).to eq mhld
    end
  end

  describe '#as_json' do
    let(:as_json) { complex_holdings.as_json }

    it 'should retun the array of libraries' do
      expect(as_json).to be_a Array
      expect(as_json.length).to eq 2
      expect(as_json.first[:code]).to eq 'library'
      expect(as_json.last[:code]).to eq 'library2'
    end
  end
end
