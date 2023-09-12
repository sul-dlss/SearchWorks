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
      subject { Holdings::Location.new("STACKS", [Holdings::Item.new({ barcode: 'barcode', library: 'GREEN', home_location: 'STACKS' })], library_code: 'GREEN') }

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
      Holdings::Item.new({ barcode: 'barcode1', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 321', shelfkey: 'ABC+321', reverse_shelfkey: 'CBA321', callnumber: 'ABC 321', full_shelfkey: '3' }),
      Holdings::Item.new({ barcode: 'barcode2', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 210', shelfkey: 'ABC+210', reverse_shelfkey: 'CBA210', callnumber: 'ABC 210', full_shelfkey: '2' }),
      Holdings::Item.new({ barcode: 'barcode3', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 100', shelfkey: 'ABC+100', reverse_shelfkey: 'CBA100', callnumber: 'ABC 100', full_shelfkey: '1' })
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
    let(:callnumbers) { [
      Holdings::Item.new({ barcode: 'barcode1', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 321', shelfkey: 'ABC+321', reverse_shelfkey: 'CBA321', callnumber: 'ABC 321', full_shelfkey: '3' }),
      Holdings::Item.new({ barcode: 'barcode2', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 210', shelfkey: 'ABC+210', reverse_shelfkey: 'CBA210', callnumber: 'ABC 210', full_shelfkey: '2' }),
      Holdings::Item.new({ barcode: 'barcode3', library: 'GREEN', home_location: 'STACKS', lopped_callnumber: 'ABC 100', shelfkey: 'ABC+100', reverse_shelfkey: 'CBA100', callnumber: 'ABC 100', full_shelfkey: '1' })
    ] }

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
