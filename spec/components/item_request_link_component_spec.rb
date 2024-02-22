require 'rails_helper'

RSpec.describe ItemRequestLinkComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(item:) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:temporary_location) { instance_double(Holdings::Location, code: nil) }
  let(:item) do
    instance_double(Holdings::Item, document:, library:, home_location: location,
                                    temporary_location: instance_double(Holdings::Location, code: nil), circulates?: true)
  end

  subject(:page) { render_inline(component) }

  context 'with FOLIO items' do
    let(:item) do
      instance_double(Holdings::Item, document:, barcode: nil, on_order?: false, library: nil, home_location: nil, temporary_location:, folio_item?: true, folio_status:, allowed_request_types:)
    end

    context 'checked out item from a location that allows holds' do
      let(:folio_status) { 'Checked out' }
      let(:allowed_request_types) { ['Hold', 'Recall'] }

      it { is_expected.to have_link 'Request' }
    end

    context 'checked out from a location that does not allow holds' do
      let(:folio_status) { 'Checked out' }
      let(:allowed_request_types) { ['Page'] }

      it { is_expected.to have_no_link 'Request' }
    end

    context 'available' do
      let(:folio_status) { 'Available' }
      let(:allowed_request_types) { ['Hold', 'Recall'] }

      it { is_expected.to have_no_link 'Request' }
    end

    context 'on-order item' do
      let(:folio_status) { 'On order' }
      let(:allowed_request_types) { [] }

      it { is_expected.to have_no_link 'Request' }
    end

    context 'on-order without a FOLIO item' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             status: 'On order',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end
  end
end
