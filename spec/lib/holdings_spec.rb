require "spec_helper"

describe Holdings do
  let(:holdings) {
    Holdings.new(
      SolrDocument.new(item_display: ['123 -|- abc'])
    )
  }
  let(:complex_holdings) {
    Holdings.new(
      SolrDocument.new(
        item_display: [
          'barcode -|- library -|- home-location -|- current-location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse-shelfkey -|- callnumber -|- full-shelfkey',
          'barcode2 -|- library2 -|- home-location2 -|- current-location2 -|- type2 -|- truncated_callnumber -|- shelfkey2 -|- reverse-shelfkey2 -|- callnumber2 -|- full-shelfkey2'
        ]
      )
    )
  }
  let(:no_holdings) { Holdings.new(SolrDocument.new) }
  describe "#callnumbers" do
    it "should return an array of Holdings::Callnumbers" do
      holdings.callnumbers.each do |callnumber|
        expect(callnumber).to be_a Holdings::Callnumber
      end
    end
    it "should return an empty array if there are no holdings" do
      expect(no_holdings.callnumbers).to eq []
    end
  end
  describe "#unique_callnumbers" do
    it "should collapse callnumbers on the truncated callnumber" do
      expect(complex_holdings.callnumbers.length).to eq 2
      expect(complex_holdings.unique_callnumbers.length).to eq 1
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
end
