# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "browse/index" do
  let(:original_doc) {
    SolrDocument.new(
      id: 'doc-id',
      item_display_struct: [
        { barcode: '123', library: 'library', effective_permanent_location_code: 'home_location', temporary_location_code: 'temporary_location_code', type: 'type',
          truncated_callnumber: 'truncated_callnumber', callnumber: 'callnumber123' },
        { barcode: '321', library: 'library', effective_permanent_location_code: 'home_location', temporary_location_code: 'temporary_location_code', type: 'type',
          truncated_callnumber: 'truncated_callnumber', callnumber: 'callnumber321' }
      ]
    )
  }
  let(:presenter) { OpenStruct.new(heading: "Title") }

  before do
    assign(:original_doc, original_doc)
    allow(view).to receive(:params).and_return(start: '123')
    expect(view).to receive(:document_presenter).with(original_doc).and_return(presenter)
  end

  it "should link to the document" do
    render
    expect(rendered).to have_css('a', text: 'Title')
  end
  describe "without barcode" do
    it "should select the first callnumber in the heading when no barcode is present" do
      render
      expect(rendered).to have_css('h1', text: "Browse related items")
      expect(rendered).to have_css('p', text: /Starting at call number:.*callnumber123/m)
    end
  end

  describe "with barcode" do
    before do
      allow(view).to receive(:params).and_return(start: '123', barcode: '321')
    end

    it "should use the callnumber based on the provided barcode in the heading" do
      render
      expect(rendered).to have_css('h1', text: "Browse related items")
      expect(rendered).to have_css('p', text: /Starting at call number:.*callnumber321/m)
    end
  end
end
