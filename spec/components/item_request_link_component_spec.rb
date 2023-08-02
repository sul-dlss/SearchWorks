require 'spec_helper'

RSpec.describe ItemRequestLinkComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(item:) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:item) do
    instance_double(Holdings::Item, document:, library:, home_location: location,
                                    current_location: instance_double(Holdings::Location, code: nil), circulates?: true)
  end

  subject(:page) { render_inline(component) }

  context "with a non-circulating item type" do
    let(:item) do
      Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- -|- REF -|-")
    end

    it { is_expected.not_to have_link 'Request' }
  end

  context 'with an item on course reserve' do
    let(:item) do
      Holdings::Item.from_item_display_string(
        '1234 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC123 -|- -|- -|- -|- course_id -|- reserve_desk -|- loan_period'
      )
    end

    it { is_expected.not_to have_link 'Request' }
  end

  context "with MEDIA-MTXT items" do
    let(:item) do
      Holdings::Item.from_item_display_string('123 -|- GREEN -|- MEDIA-MTXT -|- -|- -|- ')
    end

    it { is_expected.not_to have_link 'Request' }
  end

  describe 'ON-ORDER items' do
    let(:item) do
      Holdings::Item.from_item_display_string("123 -|- SPEC-COLL -|- STACKS -|- ON-ORDER -|- STKS-MONO")
    end

    it { is_expected.not_to have_link 'Request' }
  end

  describe "current locations" do
    context 'with -LOAN current locations' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- SOMETHING-LOAN -|- STKS-MONO", document:)
      end

      it "should require -LOAN current locations to be requested" do
        expect(page).to have_link 'Request'
      end
    end

    context 'with a SEE-LOAN current location' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- SEE-LOAN -|- STKS-MONO", document:)
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context 'with a current location of ON-ORDER' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- STKS-MONO", document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with a current location of MISSING' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- MISSING -|- STKS-MONO", document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with a current location of NEWBOOKS' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- NEWBOOKS -|- STKS-MONO", document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with an "unavailable" current location' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- INTRANSIT -|- STKS-MONO", document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with SPEC-COLL material (that will have a location-level link)' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- SPEC-COLL -|- UARCH-30 -|- ANYWHERE -|- STKS-MONO", document:)
      end

      it { is_expected.not_to have_link 'Request' }
    end
  end

  context 'with FOLIO items' do
    let(:item) do
      instance_double(Holdings::Item, document:, barcode: nil, library: nil, home_location: nil, current_location: instance_double(Holdings::Location, code: nil), folio_item?: true, folio_status:, request_policy:)
    end

    context 'checked out item from a location that allows holds' do
      let(:folio_status) { 'Checked out' }
      let(:request_policy) do
        { 'requestTypes' => ['Hold', 'Recall'] }
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'checked out from a location that does not allow holds' do
      let(:folio_status) { 'Checked out' }
      let(:request_policy) do
        { 'requestTypes' => ['Page'] }
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context 'available' do
      let(:folio_status) { 'Available' }
      let(:request_policy) do
        { 'requestTypes' => ['Hold', 'Recall'] }
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context 'on-order without a FOLIO item' do
      let(:item) do
        Holdings::Item.from_item_display_string("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- STKS-MONO", document:)
      end

      it { is_expected.to have_link 'Request' }
    end
  end
end
