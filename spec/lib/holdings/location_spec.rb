require "spec_helper"

describe Holdings::Location do
  include Marc856Fixtures
  it "should identify location level requests" do
    expect(Holdings::Location.new("SSRC-DATA")).to be_location_level_request
  end
  describe '#name' do
    let(:location_code) { "LOCKED-STK" }
    let(:callnumber) { Holdings::Callnumber.new("barcode -|- GREEN -|- #{location_code} -|- -|- -|-") }

    it "should translate the location code" do
      expect(Holdings::Location.new(location_code).name).to eq "Locked stacks: Ask at circulation desk"
    end
  end

  describe "#present?" do
    let(:location_no_items_or_mhld) {  Holdings::Location.new("STACKS") }
    let(:location_with_items) { Holdings::Location.new("STACKS", [Holdings::Callnumber.new('barcode -|- GREEN -|- STACKS -|-')]) }

    it "should be true when there are items" do
      expect(location_with_items).to be_present
    end
    it "should be present when there is an mhld" do
      expect(location_no_items_or_mhld).not_to be_present
      location_no_items_or_mhld.mhld = ['something']
      expect(location_no_items_or_mhld).to be_present
    end
    describe "present_on_index?" do
      let(:mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- something') }
      let(:library_has_mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- -|- something -|-') }

      it "should not throw an error on items w/o an mhld" do
        expect(location_no_items_or_mhld).not_to be_present_on_index
      end
      it "should return false unless the public note or latest received are present" do
        location_no_items_or_mhld.mhld = [library_has_mhld]
        expect(location_no_items_or_mhld).not_to be_present_on_index
      end
      it "should return true when an item has a present public note or latest received" do
        location_no_items_or_mhld.mhld = [mhld]
        expect(location_no_items_or_mhld).to be_present_on_index
      end
      it 'should return true for a "SEE-OTHER" location' do
        expect(described_class.new('SEE-OTHER')).to be_present_on_index
      end
    end
  end

  describe '#location_level_request?' do
    it 'should return true for items that are in request locs' do
      Constants::REQUEST_LOCS.each do |location|
        expect(Holdings::Location.new(location)).to be_location_level_request
      end
    end

    it 'returns false when then the location contains only must-request items' do
      callnumbers = [Holdings::Callnumber.new('12345 -|- GREEN -|- STACKS -|- ON-ORDER ')]
      location = Holdings::Location.new('GREEN', callnumbers)

      expect(location.send(:contains_only_must_request_items?)).to eq true
      expect(location).not_to be_location_level_request
    end

    it 'returns false when the library is a NONCIRC library that only includes INPROCESS items' do
      callnumbers = [Holdings::Callnumber.new('12345 -|- SPEC-COLL -|- STACKS -|- INPROCESS ')]
      location = Holdings::Location.new('SPEC-COLL', callnumbers)

      expect(location.send(:noncirc_library_only_inprocess?)).to eq true
      expect(location).not_to be_location_level_request
    end

    it 'returns false when the location ends in -RESV' do
      expect(Holdings::Location.new('SOMETHING-RESV')).not_to be_location_level_request
    end

    context 'HOPKINS' do
      let(:item_display) { '12345 -|- HOPKINS -|- STACKS -|- ' }
      let(:callnumbers) { [Holdings::Callnumber.new(item_display)] }
      let(:not_online_doc) { SolrDocument.new(item_display: [item_display]) }
      let(:online_doc) { SolrDocument.new(marc_links_struct: [{ fulltext: true }], item_display: [item_display]) }
      let(:multi_holdings_doc) { SolrDocument.new(item_display: [item_display, '54321 -|- GREEN -|- STACKS -|- ']) }

      it 'returns true for materials that are not available online' do
        location = Holdings::Location.new('STACKS', callnumbers, not_online_doc)
        expect(location).to be_location_level_request
      end
      it 'returns false for materials that are available online' do
        location = Holdings::Location.new('STACKS', callnumbers, online_doc)
        expect(location).not_to be_location_level_request
      end
      it 'returns false for materials that exist in other libraries' do
        location = Holdings::Location.new('STACKS', callnumbers, multi_holdings_doc)
        expect(location).not_to be_location_level_request
      end
      it 'returns false for materials that are not in STACKS' do
        location = Holdings::Location.new('REF', callnumbers, not_online_doc)
        expect(location).not_to be_location_level_request
      end
    end
  end

  describe 'external locations' do
    let(:external_location) {
      Holdings::Location.new('STACKS', [
        Holdings::Callnumber.new("LL12345 -|- LANE-MED -|- STACKS -|-  -|-  -|- ABC 321 -|-")
      ])
    }
    let(:non_external_location) {
      Holdings::Location.new("STACKS")
    }

    describe '#external_location?' do
      it 'should identify LANE-MED properly' do
        expect(external_location).to be_external_location
      end
      it 'should not identify non LANE-MED items as external locations' do
        expect(non_external_location).not_to be_external_location
      end
    end

    describe '#location_link' do
      it 'should provide a link for external locations' do
        expect(external_location.location_link).to match /http:\/\/lmldb\.stanford\.edu.*&Search_Arg=SOCW\+L12345/
      end
      it 'should strip the first "L" from the barcode' do
        expect(external_location.location_link).to match /L12345/
        expect(external_location.location_link).not_to match /LL12345/
      end
      it 'should just return a link to the lane library catalog if there are no barcoded items' do
        allow(external_location).to receive(:items).and_return([])
        external_location.mhld = [double('mhld', library: "LANE-MED")]
        expect(external_location.location_link).to eq 'http://lmldb.stanford.edu'
      end
      it 'should not provide a link for non-external locations' do
        expect(non_external_location.location_link).to be_nil
      end
    end
  end

  describe '#reserve_location?' do
    it 'is true when the location ends in -RESV' do
      expect(Holdings::Location.new('SOMETHING-RESV')).to be_reserve_location
    end
  end

  describe "sorting items" do
    let(:callnumbers) { [
      Holdings::Callnumber.new("barcode1 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 321 -|- ABC+321 -|- CBA321 -|- ABC 321 -|- 3 -|- "),
      Holdings::Callnumber.new("barcode2 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 210 -|- ABC+210 -|- CBA210 -|- ABC 210 -|- 2 -|- "),
      Holdings::Callnumber.new("barcode3 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 100 -|- ABC+100 -|- CBA100 -|- ABC 100 -|- 1 -|- ")
    ] }
    let(:location) { Holdings::Location.new("STACKS", callnumbers) }

    it "should sort items by the full shelfkey" do
      expect(location.items.map(&:callnumber)).to eq ["ABC 100", "ABC 210", "ABC 321"]
    end
  end

  describe "#bound_with?" do
    let(:location) { Holdings::Location.new("STACKS") }
    let(:bound_with_location) { Holdings::Location.new("SEE-OTHER") }

    it "should return true for locations that are SEE-OTHER" do
      expect(bound_with_location).to be_bound_with
    end
    it "should return false for locations that are not SEE-OTHER" do
      expect(location).not_to be_bound_with
    end
  end

  describe "#mhld" do
    let(:location) { Holdings::Location.new("STACKS") }

    it "should be an accessible attribute" do
      expect(location.mhld).not_to be_present
      location.mhld = "something"
      expect(location.mhld).to be_present
    end
  end

  describe '#as_json' do
    let(:callnumbers) do
      [
        Holdings::Callnumber.new('barcode1 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 321 -|- ABC+321 -|- CBA321 -|- ABC 321 -|- 3 -|- '),
        Holdings::Callnumber.new('barcode2 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 210 -|- ABC+210 -|- CBA210 -|- ABC 210 -|- 2 -|- '),
        Holdings::Callnumber.new('barcode3 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 100 -|- ABC+100 -|- CBA100 -|- ABC 100 -|- 1 -|- ')
      ]
    end
    let(:as_json) { Holdings::Location.new('STACKS', callnumbers).as_json }

    it 'should return a hash with all of the callnumbers public reader methods' do
      expect(as_json).to be_a Hash
      expect(as_json[:code]).to eq 'STACKS'
      expect(as_json[:name]).to eq 'Stacks'
    end
    it 'should return an items array' do
      expect(as_json[:items]).to be_a Array
      expect(as_json[:items].length).to eq 3
      expect(as_json[:items].first).to be_a Hash
      expect(as_json[:items].first[:library]).to eq 'GREEN'
    end
  end
end
