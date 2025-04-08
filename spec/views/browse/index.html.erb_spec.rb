# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "browse/index" do
  let(:original_doc) do
    SolrDocument.new(
      id: 'doc-id',
      browse_nearby_struct: browse_nearby_struct,
      item_display_struct: item_display_struct
    )
  end

  let(:browse_nearby_struct) do
    [
      { item_id: '123', callnumber: 'callnumber123', shelfkey: 'A', scheme: 'LC' }
    ]
  end

  let(:item_display_struct) { [] }
  let(:presenter) { OpenStruct.new(heading: "Title") }

  before do
    assign(:original_doc, original_doc)
    allow(view).to receive(:params).and_return(start: '123')
    expect(view).to receive(:document_presenter).with(original_doc).and_return(presenter)
  end

  it "links to the document" do
    render
    expect(rendered).to have_css('a', text: 'Title')
  end
  describe "without barcode" do
    it "selects the first callnumber in the heading when no barcode is present" do
      render
      expect(rendered).to have_css('h1', text: "Browse related items")
      expect(rendered).to have_css('p', text: /Starting at call number:.*callnumber123/m)
    end
  end

  describe "with barcode" do
    let(:item_display_struct) do
      [
        { barcode: '123', library: 'library', effective_permanent_location_code: 'location_code', temporary_location_code: 'temporary_location_code', type: 'type',
          truncated_callnumber: 'truncated_callnumber', callnumber: 'callnumber123' },
        { barcode: '321', library: 'library', effective_permanent_location_code: 'location_code', temporary_location_code: 'temporary_location_code', type: 'type',
          truncated_callnumber: 'truncated_callnumber', callnumber: 'callnumber321' }
      ]
    end

    before do
      allow(view).to receive(:params).and_return(start: '123', barcode: '321')
    end

    it "uses the callnumber based on the provided barcode in the heading" do
      render
      expect(rendered).to have_css('h1', text: "Browse related items")
      expect(rendered).to have_css('p', text: /Starting at call number:.*callnumber321/m)
    end
  end
end
