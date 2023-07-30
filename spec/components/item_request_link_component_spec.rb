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
      Holdings::Item.new({ barcode: '123', library: 'GREEN', home_location: 'STACKS', type: 'REF' })
    end

    it { is_expected.not_to have_link 'Request' }
  end

  context 'with an item on course reserve' do
    let(:item) do
      Holdings::Item.new({
                           barcode: '1234',
                           library: 'GREEN',
                           home_location: 'STACKS',
                           callnumber: 'ABC123',
                           course_id: 'course_id',
                           reserve_desk: 'reserve_desk',
                           loan_period: 'loan_period'
                         })
    end

    it { is_expected.not_to have_link 'Request' }
  end

  context "with MEDIA-MTXT items" do
    let(:item) do
      Holdings::Item.new({
                           barcode: '123',
                           library: 'GREEN',
                           home_location: 'MEDIA-MTXT'
                         })
    end

    it { is_expected.not_to have_link 'Request' }
  end

  describe 'ON-ORDER items' do
    let(:item) do
      Holdings::Item.new({
                           barcode: '123',
                           library: 'SPEC-COLL',
                           home_location: 'STACKS',
                           current_location: 'ON-ORDER',
                           type: 'STKS-MONO'
                         })
    end

    it { is_expected.not_to have_link 'Request' }
  end

  describe "current locations" do
    context 'with -LOAN current locations' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'SOMETHING-LOAN',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it "should require -LOAN current locations to be requested" do
        expect(page).to have_link 'Request'
      end
    end

    context 'with a SEE-LOAN current location' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'SEE-LOAN',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context 'with a current location of ON-ORDER' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'ON-ORDER',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with a current location of MISSING' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'MISSING',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with a current location of NEWBOOKS' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'NEWBOOKS',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with an "unavailable" current location' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'INTRANSIT',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end

    context 'with SPEC-COLL material (that will have a location-level link)' do
      let(:item) do
        Holdings::Item.new({
                             barcode: '123',
                             library: 'SPEC-COLL',
                             home_location: 'UARCH-30',
                             current_location: 'ANYWHERE',
                             type: 'STKS-MONO'
                           }, document:)
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
        Holdings::Item.new({
                             barcode: '123',
                             library: 'GREEN',
                             home_location: 'STACKS',
                             current_location: 'ON-ORDER',
                             type: 'STKS-MONO'
                           }, document:)
      end

      it { is_expected.to have_link 'Request' }
    end
  end
end
