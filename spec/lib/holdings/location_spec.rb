# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings::Location do
  describe '#name' do
    let(:location_code) { "GRE-LOCKED-STK" }

    it "looks up the label from the Folio data" do
      expect(described_class.new(location_code).name).to eq "Locked stacks: Ask at circulation desk"
    end
  end

  describe "#present?" do
    context 'when there are items' do
      subject { described_class.new("GRE-STACKS", [Holdings::Item.new({ barcode: 'barcode', library: 'GREEN', effective_permanent_location_code: 'STACKS' })]) }

      it { is_expected.to be_present }
    end

    context 'when there are no items or mhld' do
      subject { described_class.new("GRE-STACKS") }

      it { is_expected.not_to be_present }
    end

    context 'when there are mhld but no items' do
      subject { described_class.new("GRE-STACKS", [], ['something']) }

      it { is_expected.to be_present }
    end
  end

  describe "present_on_index?" do
    context 'when there is an item without an mhld' do
      subject { described_class.new("GRE-STACKS") }

      it { is_expected.not_to be_present_on_index }
    end

    context 'when the public note or latest received are not present' do
      let(:library_has_mhld) { Holdings::MHLD.new('GREEN -|- GRE-STACKS -|- -|- something -|-') }

      subject { described_class.new("GRE-STACKS", [], [library_has_mhld]) }

      it { is_expected.not_to be_present_on_index }
    end

    context 'when an item has a present public note or latest received' do
      let(:mhld) { Holdings::MHLD.new('GREEN -|- GRE-STACKS -|- something') }

      subject { described_class.new("GRE-STACKS", [], [mhld]) }

      it { is_expected.to be_present_on_index }
    end
  end

  describe '#location_link' do
    subject(:location_link) { location.location_link }

    context 'with non-external location' do
      let(:location) { described_class.new("GRE-STACKS") }

      it 'does not provide a link' do
        expect(location_link).to be_nil
      end
    end
  end

  describe "#items" do
    subject(:items) { location.items }

    let(:callnumbers) { [
      Holdings::Item.new({ barcode: 'barcode1', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', lopped_callnumber: 'ABC 321', shelfkey: 'ABC+321',
                           reverse_shelfkey: 'CBA321', callnumber: 'ABC 321', full_shelfkey: '3' }),
      Holdings::Item.new({ barcode: 'barcode2', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', lopped_callnumber: 'ABC 210', shelfkey: 'ABC+210',
                           reverse_shelfkey: 'CBA210', callnumber: 'ABC 210', full_shelfkey: '2' }),
      Holdings::Item.new({ barcode: 'barcode3', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', lopped_callnumber: 'ABC 100', shelfkey: 'ABC+100',
                           reverse_shelfkey: 'CBA100', callnumber: 'ABC 100', full_shelfkey: '1' })
    ] }
    let(:location) { described_class.new("GRE-STACKS", callnumbers) }

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
                    id: "158168a3-ede4-4cc1-8c98-61f4feeb22ea",
                    code: "SAL3-SEE-OTHER",
                    name: "See linked record to request items bound together",
                    campus: {
                      id: "c365047a-51f2-45ce-8601-e421ca3615c5",
                      code: "SUL",
                      name: "Stanford Libraries"
                    },
                    details: {},
                    library: {
                      id: "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                      code: "SAL3",
                      name: "SAL3 (off-campus storage)"
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

      subject { described_class.new("SAL3-STACKS", [
        Holdings::Item.new({ barcode: '1234', library: 'SAL3', effective_permanent_location_code: 'SAL3-STACKS' }, document:)
      ]) }

      it { is_expected.to be_bound_with }
    end

    context 'with items that are not bound with' do
      subject { described_class.new("GRE-STACKS", [
        Holdings::Item.new({ barcode: 'barcode2', library: 'GREEN', effective_permanent_location_code: 'SEE-OTHER' }, document: SolrDocument.new)
      ]) }

      it { is_expected.not_to be_bound_with }
    end
  end

  context 'with a location that has a stackmap api url' do
    subject { described_class.new("GRE-STACKS") }

    describe '#stackmap_api_url' do
      it 'returns the stackmap api url' do
        expect(subject.stackmap_api_url).to eq "https://stanford.stackmap.com/json/"
      end
    end

    describe '#stackmapable?' do
      it 'returns true' do
        expect(subject.stackmapable?).to be true
      end
    end
  end

  context 'with a location that has no stackmap api url' do
    subject { described_class.new("LOCKED-STK") }

    describe '#stackmap_api_url' do
      it 'returns nil' do
        expect(subject.stackmap_api_url).to be_nil
      end
    end

    describe '#stackmapable?' do
      it 'returns false' do
        expect(subject.stackmapable?).to be false
      end
    end
  end
end
