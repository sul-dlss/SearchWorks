require "spec_helper"

describe "catalog/mastheads/_callnumber_browse.html.erb" do
  let(:original_doc) { 
    SolrDocument.new(
      id: 'doc-id',
      item_display: [
        "123 -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber123",
        "321 -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber321"
      ]
    )
  }
  let(:presenter) { OpenStruct.new(document_heading: "Title") }
  before do
    assign(:original_doc, original_doc)
    expect(view).to receive(:presenter).with(original_doc).and_return(presenter)
  end
  it "should link to the document" do
    render
    expect(rendered).to have_css('a', 'doc-id')
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
      allow(view).to receive(:params).and_return(barcode: '321')
    end
    it "should use the callnumber based on the provided barcode in the heading" do
      render
      expect(rendered).to have_css('h1', text: "Browse related items")
      expect(rendered).to have_css('p', text: /Starting at call number:.*callnumber321/m)
    end
  end
end
