# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult::LocationComponent, type: :component do
  let(:component) { described_class.new(library:, document:) }
  let(:library) { document.holdings.libraries.first }

  subject(:page) { render_inline(component) }

  context 'with multiple items in a location' do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' },
          { barcode: '456', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 456' }
        ]
      )
    end

    it "renders the table" do
      expect(page).to have_css('caption.sr-only', text: 'Status of items at Green Library')
      expect(page).to have_css('th[scope="col"]', text: 'Green Library')
      expect(page).to have_css('th[scope="col"]', text: 'Status')
      expect(page).to have_css('tbody th[scope="col"]', text: 'Stacks')
      expect(page).to have_css('tbody td', text: "ABC 123")
      expect(page).to have_css('tbody td', text: "ABC 456")
    end
  end

  describe "records with mhlds" do
    context "with matching library/location" do
      let(:document) do
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '321', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' }
          ],
          mhld_display: ['GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received']
        )
      end

      it "includes the matched MHLD" do
        expect(page).to have_css('tbody tr', count: 2)
        expect(page).to have_css('tbody tr th', text: /Stacks.*public note/m)
        expect(page).to have_css('tbody tr td', text: "ABC 123")
        expect(page).to have_css('tbody tr td', text: "Latest: latest received")
      end
    end

    context 'with multiple library has statements' do
      let(:document) do
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '321', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' }
          ],
          mhld_display: [
            'GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received',
            'GREEN -|- GRE-STACKS -|- public note -|- library has2 -|- latest received'
          ]
        )
      end

      it "includes the latest received data only once" do
        expect(page).to have_css('tbody tr .note-highlight', text: "Latest: latest received", count: 1)
      end
    end

    context "with no matching library/location" do
      context "with latest received" do
        let(:document) do
          SolrDocument.new(
            id: '123',
            mhld_display: ['GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received']
          )
        end

        it "shows the appropriate mhld data" do
          expect(page).to have_css('tbody tr', count: 1)
          expect(page).to have_css('tbody tr th', text: /Stacks.*public note/m)
          expect(page).to have_css('tbody tr td', text: "Latest: latest received")
        end
      end

      context "with only library has" do # https://searchworks.stanford.edu/view/1463888
        let(:document) do
          SolrDocument.new(
            id: '123',
            mhld_display: ['GREEN -|- GRE-STACKS -|- -|- library has -|- ']
          )
        end

        it "renders nothing" do
          expect(page).to have_no_selector('body')
        end
      end
    end

    context "with mhld that only has 'Library has' statement" do
      let(:document) do
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' }
          ],
          mhld_display: ['GREEN -|- GRE-CURRENTPER -|- -|- library has -|-']
        )
      end

      it "does not display the location" do
        expect(page).to have_css('tbody tr', count: 2)
        expect(page).to have_no_content('library has')
        expect(page).to have_no_content('Current periodicals')
      end
    end
  end

  describe "bound with" do
    context 'with bound-with in SAL3 and a regular holding in SPEC-COLL' do
      let(:document) do
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { id: '66645303-add1-5d4f-ae33-7944f5d1cae2', barcode: '36105097469808', library: 'SPEC-COLL',
              effective_permanent_location_code: 'SPEC-SAMSON', callnumber: 'PJ5204 .B6 1866' },
            { id: '086a8f9d-bece-5919-afe9-fdc65f970d36', barcode: '36105023721066', library: 'SAL3',
              effective_permanent_location_code: 'SAL3-STACKS', callnumber: 'PJ5204 .B6 1838 2ND IN VOL' }
          ],
          holdings_json_struct: [
            {
              holdings: [
                {
                  id: 'd2777d47-2150-54aa-a5f8-50c2d4042338',
                  boundWith: {
                    item: {
                      id: '086a8f9d-bece-5919-afe9-fdc65f970d36'
                    },
                    holding: {},
                    instance: {}
                  },
                  location: {
                    effectiveLocation: build(:location, code: 'SAL3-SEE-OTHER')
                  }
                },
                {
                  id: '971f9a6d-7650-5793-898a-5927b9378570',
                  location: {
                    effectiveLocation: build(:location, code: 'SPEC-SAMSON')
                  }
                }
              ]
            }
          ]
        )
      end

      context 'when looking at SAL3' do
        let(:library) { document.holdings.libraries.first }

        it "shows the message" do
          expect(page).to have_content 'Some records bound together'
        end
      end

      context 'when looking at SPEC-COLL' do
        let(:library) { document.holdings.libraries.last }

        it "doesn't show" do
          expect(page).to have_no_content 'Some records bound together'
        end
      end
    end
  end
end
