require 'rails_helper'

RSpec.describe Holdings::Status do
  let(:status) { Holdings::Status.new(OpenStruct.new) }

  describe '#as_json' do
    let(:as_json) { status.as_json }

    it 'should return a json hash with the availability class and status text' do
      expect(as_json).to have_key :availability_class
      expect(as_json).to have_key :status_text
    end
  end

  describe '#availability_class' do
    let(:item) do
      instance_double(Holdings::Item, folio_item?: true, folio_status: nil, effective_location:)
    end
    let(:effective_location) do
      instance_double(Folio::Location, details: {})
    end

    subject(:availability) { described_class.new(item).availability_class }

    context 'when the item has a FOLIO status that makes it in-process' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'In process', effective_location:)
      end

      it { is_expected.to eq 'in_process' }
    end

    context 'when the item has a location that makes it in-process (e.g. a SUL-TS processing location)' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location:)
      end

      let(:effective_location) do
        instance_double(Folio::Location, details: { 'availabilityClass' => 'In_process' })
      end

      it { is_expected.to eq 'in_process' }
    end

    context 'when the item has a FOLIO status that makes it unavailable' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Missing', effective_location:)
      end

      it { is_expected.to eq 'unavailable' }
    end

    context 'when the item has a location that makes it unavailable' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location:)
      end

      let(:effective_location) do
        instance_double(Folio::Location, details: { 'availabilityClass' => 'Unavailable' })
      end

      it { is_expected.to eq 'unavailable' }
    end

    context 'on-order but without an item' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: false, on_order?: true)
      end

      it { is_expected.to eq 'unavailable' }
    end

    context 'when the item is in a remote location' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location:, circulates?: true)
      end
      let(:effective_location) do
        instance_double(Folio::Location, details: { 'availabilityClass' => 'Offsite' })
      end

      it { is_expected.to eq 'deliver-from-offsite' }
    end

    context 'when a non-circulating item is in a remote location' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location:, circulates?: false)
      end
      let(:effective_location) do
        instance_double(Folio::Location, details: { 'availabilityClass' => 'Offsite' })
      end

      it { is_expected.to eq 'noncirc_page' }
    end

    context 'when the item is non-circulating' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location:, circulates?: false)
      end

      it { is_expected.to eq 'noncirc' }
    end

    context 'when the item is marked as available because of its location' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'On hold for a borrower', effective_location:, circulates?: true)
      end
      let(:effective_location) do
        instance_double(Folio::Location, details: { 'availabilityClass' => 'Available' })
      end

      it { is_expected.to eq 'available' }
    end

    context 'when the item needs a live lookup' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: true, folio_status: 'Available', effective_location: instance_double(Folio::Location, details: {}), circulates?: true)
      end

      it { is_expected.to eq 'unknown' }
    end

    context 'there is not a folio item but it also is not on order (e.g. maybe it is a bound-with?)' do
      let(:item) do
        instance_double(Holdings::Item, folio_item?: false, on_order?: false)
      end

      it { is_expected.to eq 'unknown' }
    end
  end
end
