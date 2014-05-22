require 'spec_helper'

describe "catalog/record/_marc_contents_summary.html.erb" do
  include MarcMetadataFixtures
  include Marc856Fixtures

  describe "finding aids" do
    before do
      assign(:document, SolrDocument.new(marcxml: finding_aid_856) )
    end
    it "should be displayed when present" do
      render
      expect(rendered).to have_css("dt", text: "Finding aid")
      expect(rendered).to have_css("dd", text: "FINDING AID:")
      expect(rendered).to have_css("dd a", text: "Link text")
    end
  end
  it "should be blank if the document has not fields" do
    assign(:document, SolrDocument.new(marcxml: no_fields_fixture))
    render
    expect(rendered).to be_blank
  end
end
