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

  context 'with a Folio item' do
    let(:policy) { instance_double(ItemRequestLinkPolicy, show?: true) }
    let(:item) do
      instance_double(Holdings::Item, document:, library:, effective_location:, home_location: location, barcode: 13_333_333_333_333, folio_item?: true)
    end

    before do
      allow(ItemRequestLinkPolicy).to receive(:new).and_return(policy)
    end

    context 'with an onsite page location' do
      let(:effective_location) do
        Folio::Location.from_dynamic(
          {
            'id' => 'f155b1bc-7d19-402a-8412-431988b12cc3',
            'code' => 'SAL3-PAGE-AS',
            'name' => 'Off-campus storage',
            'institution' => {
              'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
              'code' => 'SU',
              'name' => 'Stanford University'
            },
            'campus' => {
              'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
              'code' => 'SUL',
              'name' => 'Stanford Libraries'
            },
            'library' => {
              'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
              'code' => 'SAL3',
              'name' => 'Stanford Auxiliary Library 3'
            }
          }
        )
      end

      it { is_expected.to have_link 'Request on-site access' }
    end
  end
end
