require "spec_helper"

describe Holdings do
  let(:holdings) {
    Holdings.new(
      SolrDocument.new(item_display: ['123 -|- abc']).callnumbers
    )
  }
  let(:complex_holdings) {
    Holdings.new(
      SolrDocument.new(
        item_display: [
          'barcode -|- library -|- home-location -|- current-location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse-shelfkey -|- callnumber -|- full-shelfkey -|- -|- LC',
          'barcode2 -|- library2 -|- home-location2 -|- current-location2 -|- type2 -|- truncated_callnumber -|- shelfkey2 -|- reverse-shelfkey2 -|- callnumber2 -|- full-shelfkey2 -|- -|- INTERNET'
        ]
      ).callnumbers
    )
  }
  let(:sortable_holdings) {
    Holdings.new(
      SolrDocument.new(
        item_display: [
          'barcode -|- library -|- home-location -|- current-location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse-shelfkey -|- callnumber -|- 999',
          'barcode2 -|- library2 -|- home-location2 -|- current-location2 -|- type2 -|- truncated_callnumber -|- shelfkey2 -|- reverse-shelfkey2 -|- callnumber2 -|- 111'
        ]
      ).callnumbers
    )
  }
  let(:no_holdings) { Holdings.new([]) }

  describe "#present?" do
    let(:blank_callnumber) {
      Holdings.new([])
    }

    it "should return false if there are no holdings" do
      expect(no_holdings).not_to be_present
    end
    it "should return false if an item's call number is blank" do
      expect(blank_callnumber).not_to be_present
    end
    it "should return true if there are items in a viewable library" do
      expect(complex_holdings).to be_present
    end
  end

  describe "#callnumbers" do
    it "should return an array of Holdings::Callnumbers" do
      holdings.callnumbers.each do |callnumber|
        expect(callnumber).to be_a Holdings::Callnumber
      end
    end
    it "should return an empty array if there are no holdings" do
      expect(no_holdings.callnumbers).to eq []
    end
    it "should be sorted by the shelfkey" do
      expect(sortable_holdings.callnumbers.map(&:full_shelfkey)).to eq ['111', '999']
    end
  end

  describe "#libraries" do
    let(:libraries) {
      Holdings.new(
        SolrDocument.new(
          item_display: [
            'barcode -|- library -|- home-location',
            'barcode -|- library2 -|- home-location',
            'barcode -|- library -|- home-location'
          ]
        ).callnumbers
      )
    }
    let(:sortable_libraries) {
      Holdings.new(
        SolrDocument.new(
          item_display: [
            'barcode -|- SAL3 -|- home-location',
            'barcode -|- GREEN -|- home-location',
            'barcode -|- BIOLOGY -|- home-location'
          ]
        ).callnumbers
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
      expect(sortable_libraries.libraries.map(&:code)).to eq ['GREEN', 'BIOLOGY', 'SAL3']
    end
  end

  describe "#browsable_callnumbers" do
    it "should collapse callnumbers on the truncated callnumber" do
      expect(complex_holdings.callnumbers.length).to eq 2
      expect(complex_holdings.browsable_callnumbers.length).to eq 1
    end
  end

  describe "#find_by_barcode" do
    let(:found) { complex_holdings.find_by_barcode('barcode2') }

    it "should return a single Holdings::Callnumber" do
      expect(found).to be_a Holdings::Callnumber
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
        item_display: ['barcode -|- GREEN -|- STACKS -|- current-location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse-shelfkey -|- callnumber'],
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
      expect(location.items.first).to be_a Holdings::Callnumber
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
