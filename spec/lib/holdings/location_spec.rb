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

    context 'with an external location' do
      let(:location) do
        Holdings::Location.new('STACKS', [
          Holdings::Item.new({
                               barcode: 'LL12345',
                               library: 'LANE-MED',
                               home_location: 'STACKS',
                               lopped_callnumber: 'ABC 321'
                             })
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
    context 'with items that are bound with' do
      let(:document) {
        SolrDocument.new(
          id: '1234',
          holdings_json_struct: [
            { holdings: [
              {
                id: 'holding1234',
                location: {
                  effectiveLocation: {
                    id: "4573e824-9273-4f13-972f-cff7bf504217",
                    code: "SEE-OTHER",
                    name: "Bound With Test",
                    campus: {
                      id: "c365047a-51f2-45ce-8601-e421ca3615c5",
                      code: "SUL",
                      name: "Stanford Libraries"
                    },
                    details: {},
                    library: {
                      id: "f6b5519e-88d9-413e-924d-9ed96255f72e",
                      code: "GREEN",
                      name: "Cecil H. Green"
                    },
                    institution: {
                      id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                      code: "SU",
                      name: "Stanford University"
                    }
                  }
                },
                holdingsType: {
                  id: "5b08b35d-aaa3-4806-998c-9cd85e5bc406",
                  name: "Bound-with"
                },
                boundWith: {
                  item: { barcode: "1234" },
                  instance: { id: "7e194e58-e134-56fe-a3c2-2c0494e04c5b" }
                }
              }
            ] }
          ]
        )
      }

      subject { Holdings::Location.new("STACKS", [
        Holdings::Item.new({ barcode: '1234', library: 'GREEN', home_location: 'SEE-OTHER' }, document:)
      ], library_code: 'GREEN') }

      it { is_expected.to be_bound_with }
    end

    context 'with items that are not bound with' do
      subject { Holdings::Location.new("STACKS", [
        Holdings::Item.new({ barcode: 'barcode2', library: 'GREEN', home_location: 'SEE-OTHER' }, document: SolrDocument.new)
      ], library_code: 'GREEN') }

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
