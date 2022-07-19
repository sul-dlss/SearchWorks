require 'spec_helper'

RSpec.describe ItemRequestLinkComponent, type: :component do
  include MarcMetadataFixtures

  let(:component) { described_class.new(item: item) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:item) do
    instance_double(Holdings::Callnumber, document: document, library: library, home_location: location, current_location: double(code: nil), circulates?: true)
  end

  subject(:page) { render_inline(component) }

  describe "#show_item_level_request_link?" do
    context "with a non-circulating item type" do
      let(:item) do
        Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- -|- REF -|-")
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context 'with an item on course reserve' do
      let(:item) do
        Holdings::Callnumber.new(
          '1234 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC123 -|- -|- -|- -|- course_id -|- reserve_desk -|- loan_period'
        )
      end

      it { is_expected.not_to have_link 'Request' }
    end

    context "with MEDIA-MTXT items" do
      let(:item) do
        Holdings::Callnumber.new('123 -|- GREEN -|- MEDIA-MTXT -|- -|- -|- ')
      end

      it { is_expected.not_to have_link 'Request' }
    end

    describe 'ON-ORDER items' do
      let(:item) do
        Holdings::Callnumber.new("123 -|- SPEC-COLL -|- STACKS -|- ON-ORDER -|- STKS-MONO")
      end

      it { is_expected.not_to have_link 'Request' }
    end

    describe "current locations" do
      context 'with -LOAN current locations' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SOMETHING-LOAN -|- STKS-MONO", document: document)
        end

        it "should require -LOAN current locations to be requested" do
          expect(page).to have_link 'Request'
        end
      end

      context 'with a SEE-LOAN current location' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SEE-LOAN -|- STKS-MONO", document: document)
        end

        it { is_expected.not_to have_link 'Request' }
      end

      context 'with a current location of ON-ORDER' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- STKS-MONO", document: document)
        end

        it { is_expected.to have_link 'Request' }
      end

      context 'with a current location of MISSING' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- MISSING -|- STKS-MONO", document: document)
        end

        it { is_expected.to have_link 'Request' }
      end

      context 'with a current location of NEWBOOKS' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- NEWBOOKS -|- STKS-MONO", document: document)
        end

        it { is_expected.to have_link 'Request' }
      end

      context 'with an "unavailable" current location' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- INTRANSIT -|- STKS-MONO", document: document)
        end

        it { is_expected.to have_link 'Request' }
      end

      context 'with SPEC-COLL material (that will have a location-level link)' do
        let(:item) do
          Holdings::Callnumber.new("123 -|- SPEC-COLL -|- UARCH-30 -|- ANYWHERE -|- STKS-MONO", document: document)
        end

        it { is_expected.not_to have_link 'Request' }
      end
    end
  end
end
