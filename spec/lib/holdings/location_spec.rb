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

  describe "#bound_with_child?" do
    let(:document) { SolrDocument.new }

    context 'with items that are bound with' do
      subject do
        described_class.new("SAL3-STACKS", [
          Holdings::Item.new(
            {
              barcode: '1234', library: 'SAL3', effective_permanent_location_code: 'SAL3-STACKS',
              bound_with: {
                hrid: 'a5488051'
              }
            },
            document:
          )
        ])
      end

      it { is_expected.to be_bound_with_child }
    end

    context 'with items that are not bound with' do
      subject do
        described_class.new("GRE-STACKS", [
          Holdings::Item.new(
            { barcode: 'barcode2', library: 'GREEN', effective_permanent_location_code: 'SEE-OTHER' },
            document:
          )
        ])
      end

      it { is_expected.not_to be_bound_with_child }
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
