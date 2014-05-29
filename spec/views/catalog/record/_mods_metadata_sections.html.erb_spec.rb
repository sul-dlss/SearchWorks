require "spec_helper"

describe "catalog/record/_mods_metadata_sections.html.erb" do
  include ModsFixtures

  describe "Metadata sections all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    before do
      assign(:document, document)
    end
    it "should display correct sections" do
      render
      expect(rendered).to have_css("h2", text: "Abstract/Contents")
      expect(rendered).to have_css("h2", text: "Subjects")
      expect(rendered).to have_css("h2", text: "Bibliographic information")
      expect(rendered).to have_css("h2", text: "Access conditions")
    end
  end

  describe "Metadata sections none available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }
    before do
      assign(:document, document)
    end
    it "should display correct sections" do
      render
      expect(rendered).to_not have_css("h2", text: "Abstract/Contents")
      expect(rendered).to_not have_css("h2", text: "Subjects")
      expect(rendered).to_not have_css("h2", text: "Bibliographic information")
      expect(rendered).to_not have_css("h2", text: "Access conditions")
    end
  end
end
