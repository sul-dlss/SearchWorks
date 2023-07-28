require "spec_helper"

RSpec.describe Holdings::Location do
  include Marc856Fixtures
  describe '#name' do
    let(:location_code) { "LOCKED-STK" }

    it "looks up the label from the Folio data" do
      expect(Holdings::Location.new(location_code, library_code: 'GREEN').name).to eq "Locked stacks: Ask at circulation desk"
    end
  end

  describe "#present?" do
    context 'when there are items' do
      subject { Holdings::Location.new("STACKS", [Holdings::Item.from_item_display_string('barcode -|- GREEN -|- STACKS -|-')], library_code: 'GREEN') }

      it { is_expected.to be_present }
    end

    context 'when there are no items or mhld' do
      subject {  Holdings::Location.new("STACKS", library_code: 'GREEN') }

      it { is_expected.not_to be_present }
    end

    context 'when there are mhld but no items' do
      subject { Holdings::Location.new("STACKS", [], ['something'], library_code: 'GREEN') }

      it { is_expected.to be_present }
    end
  end

  describe "present_on_index?" do
    context 'when there is an item without an mhld' do
      subject { Holdings::Location.new("STACKS", library_code: 'GREEN') }

      it { is_expected.not_to be_present_on_index }
    end

    context 'when the public note or latest received are not present' do
      let(:library_has_mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- -|- something -|-') }

      subject { Holdings::Location.new("STACKS", [], [library_has_mhld], library_code: 'GREEN') }

      it { is_expected.not_to be_present_on_index }
    end

    context 'when an item has a present public note or latest received' do
      let(:mhld) { Holdings::MHLD.new('GREEN -|- STACKS -|- something') }

      subject { Holdings::Location.new("STACKS", [], [mhld], library_code: 'GREEN') }

      it { is_expected.to be_present_on_index }
    end

    context 'for a SEE-OTHER location' do
      subject { described_class.new('SEE-OTHER', library_code: 'HOPKINS') }

      it { is_expected.to be_present_on_index }
    end
  end

  describe '#location_link' do
    subject(:location_link) { location.location_link }

    context 'with an external location' do
      let(:location) do
        Holdings::Location.new('STACKS', [
          Holdings::Item.from_item_display_string("LL12345 -|- LANE-MED -|- STACKS -|-  -|-  -|- ABC 321 -|-")
        ], library_code: 'LANE-MED')
      end

      it 'provides a link for external locations' do
        expect(location_link).to match %r{https://lane.stanford.edu/view/bib/12345}
      end

      it 'strips the first "L" from the barcode' do
        expect(location_link).to match /12345/
        expect(location_link).not_to match /LL12345/
      end
    end

    context 'with an external location with no barcodes' do
      let(:location) {
        Holdings::Location.new('STACKS', [], [double('mhld', library: "LANE-MED")], library_code: 'LANE-MED')
      }

      it 'returns a link to the lane library catalog' do
        expect(location_link).to eq 'https://lane.stanford.edu'
      end
    end

    context 'with non-external location' do
      let(:location) { Holdings::Location.new("STACKS", library_code: 'GREEN') }

      it 'does not provide a link' do
        expect(location_link).to be_nil
      end
    end
  end

  describe "#items" do
    subject(:items) { location.items }

    let(:callnumbers) { [
      Holdings::Item.from_item_display_string("barcode1 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 321 -|- ABC+321 -|- CBA321 -|- ABC 321 -|- 3 -|- "),
      Holdings::Item.from_item_display_string("barcode2 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 210 -|- ABC+210 -|- CBA210 -|- ABC 210 -|- 2 -|- "),
      Holdings::Item.from_item_display_string("barcode3 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 100 -|- ABC+100 -|- CBA100 -|- ABC 100 -|- 1 -|- ")
    ] }
    let(:location) { Holdings::Location.new("STACKS", callnumbers, library_code: 'GREEN') }

    it "sorts items by the full shelfkey" do
      expect(items.map(&:callnumber)).to eq ["ABC 100", "ABC 210", "ABC 321"]
    end
  end

  describe "#bound_with?" do
    context 'with locations that are SEE-OTHER' do
      subject { Holdings::Location.new("SEE-OTHER", library_code: 'HOPKINS') }

      it { is_expected.to be_bound_with }
    end

    context 'with locations that are not SEE-OTHER' do
      subject { Holdings::Location.new("STACKS", library_code: 'GREEN') }

      it { is_expected.not_to be_bound_with }
    end
  end

  describe '#as_json' do
    let(:callnumbers) do
      [
        Holdings::Item.from_item_display_string('barcode1 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 321 -|- ABC+321 -|- CBA321 -|- ABC 321 -|- 3 -|- '),
        Holdings::Item.from_item_display_string('barcode2 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 210 -|- ABC+210 -|- CBA210 -|- ABC 210 -|- 2 -|- '),
        Holdings::Item.from_item_display_string('barcode3 -|- GREEN -|- STACKS -|-  -|-  -|- ABC 100 -|- ABC+100 -|- CBA100 -|- ABC 100 -|- 1 -|- ')
      ]
    end

    subject(:as_json) { Holdings::Location.new('STACKS', callnumbers, library_code: 'GREEN').as_json }

    it 'returns a hash with all of the callnumbers public reader methods' do
      expect(as_json).to be_a Hash
      expect(as_json[:code]).to eq 'STACKS'
      expect(as_json[:name]).to eq 'Stacks'
      expect(as_json[:items]).to be_a Array
      expect(as_json[:items].length).to eq 3
      expect(as_json[:items].first).to be_a Hash
      expect(as_json[:items].first[:library]).to eq 'GREEN'
    end
  end
end
