require "spec_helper"

describe "catalog/record/_marc_bibliographic.html.erb" do
  include MarcMetadataFixtures

  describe "MARC 592" do
    let(:document) { SolrDocument.new(marcxml: marc_592_fixture) }
    before do
      assign(:document, document)
    end
    it "should display for databases" do
      document.stub(:is_a_database?).and_return(true)
      render
      expect(rendered).to have_css("dt", text: "Note")
      expect(rendered).to have_css("dd", text: "A local note added to subjects only")
    end
    it "should not display for non-databases" do
      document.stub(:is_a_database?).and_return(false)
      render
      expect(rendered).to_not have_css("dt", text: "Note")
      expect(rendered).to_not have_css("dd", text: "A local note added to subjects only")
    end
  end

  describe "MARC 245C" do
    let(:document) { SolrDocument.new(marcxml: metadata1) }
    before do
      assign(:document, document)
    end
    it "should display for for 245C field" do
      render
      expect(rendered).to have_css("dt", text: "Responsibility")
      expect(rendered).to have_css("dd", text: "Most responsible person ever")
    end
  end
end
