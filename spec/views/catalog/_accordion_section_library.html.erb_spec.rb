require 'rails_helper'

RSpec.describe "catalog/_accordion_section_library" do
  before do
    allow(view).to receive(:document).and_return(document)
  end

  describe "Accordion section - library" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', callnumber: 'ABC 123' }
        ]
      )
    end

    before do
      render
    end

    it "should include the library accordion and text" do
      expect(rendered).to have_css('.accordion-section.location')
      expect(rendered).to have_css('.accordion-section.location button.header[aria-expanded="false"]', text: "Check availability")
      expect(rendered).to have_css('.accordion-section.location span.snippet', text: "Green Library")
      expect(rendered).to have_css('.accordion-section .details[aria-expanded="false"]')
      expect(rendered).to have_css('.accordion-section .details tbody tr', count: 2)
      expect(rendered).to have_css('.accordion-section .details tbody tr th', text: /Stacks/)
      expect(rendered).to have_css('.accordion-section .details tbody tr td', text: /ABC 123/)
    end
  end

  describe 'location level requests' do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'ART', effective_permanent_location_code: 'ART-LOCKED-LARGE', type: 'STKS-MONO', callnumber: 'ABC 123' }
        ]
      )
    end

    let(:book_type) do
      Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
    end

    before do
      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '123', barcode: '123',
                                     effective_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                     permanent_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                     location_provided_availability: nil,
                                     status: 'Available', material_type: book_type,
                                     loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])
      render
    end

    it 'has the request link at the location level' do
      expect(rendered).to have_css('tbody th strong', text: /Locked stacks/)
      expect(rendered).to have_css('tbody td a', text: "Request")
    end
  end

  describe "status icon" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'SAL3', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 123' }
        ]
      )
    end

    let(:sal3_location) do
      Folio::Types.cached_location_by_code('SAL3-STACKS')
    end

    let(:book_type) do
      Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
    end

    before do
      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '123', barcode: '123',
                                     effective_location: sal3_location,
                                     permanent_location: sal3_location,
                                     location_provided_availability: 'Offsite',
                                     status: 'Available', material_type: book_type,
                                     loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])
      allow(view).to receive(:document).and_return(document)
      render
    end

    it "includes the status icon" do
      expect(rendered).to have_css('tbody td i.deliver-from-offsite')
    end
  end

  describe "status text" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 123' },
          { id: '321', barcode: '321', library: 'SPEC-COLL', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 321' }
        ]
      )
    end
    let(:spec_location) do
      Folio::Types.cached_location_by_code('SPEC-MANUSCRIPT')
    end

    before do
      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '321', barcode: '321',
                                     effective_location: spec_location,
                                     permanent_location: spec_location,
                                     location_provided_availability: nil,
                                     status: 'Available',
                                     material_type: instance_double(Folio::Item::MaterialType, id: nil),
                                     loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])
      render
    end

    it "has unknown status text for items we'll be looking up" do
      expect(rendered).to have_css('.status-text', text: 'Unknown')
    end

    it "has explicit status text for items that we know the status" do
      expect(rendered).to have_css('.status-text', text: 'In-library use')
    end
  end

  describe "request links" do
    describe "location level request links" do
      describe "for multiple items" do
        let(:document) do
          SolrDocument.new(
            id: '123',
            item_display_struct: [
              { barcode: '123', library: 'ART', effective_permanent_location_code: 'ART-LOCKED-LARGE', callnumber: 'ABC 123' },
              { barcode: '456', library: 'ART', effective_permanent_location_code: 'ART-LOCKED-LARGE', status: 'On order', type: 'STKS-MONO', callnumber: 'ABC 456' }
            ]
          )
        end

        let(:book_type) do
          Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
        end

        before do
          allow(document).to receive(:folio_items).and_return([
            instance_double(Folio::Item, id: '123', barcode: '123',
                                         effective_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                         permanent_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                         location_provided_availability: nil,
                                         status: 'Available', material_type: book_type,
                                         loan_type: instance_double(Folio::Item::LoanType, id: nil)),
            instance_double(Folio::Item, id: '456', barcode: '456',
                                         effective_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                         permanent_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                         location_provided_availability: nil,
                                         status: 'On order', material_type: book_type,
                                         loan_type: instance_double(Folio::Item::LoanType, id: nil))
          ])
          render
        end

        it "puts the request in the row w/ the location (since there will be multiple rows for callnumbers)" do
          expect(rendered).to have_css('tbody td a', text: 'Request')
          expect(rendered).to have_no_css('tbody td[data-item-id] a', text: 'Request')
        end
      end
    end
  end
end
