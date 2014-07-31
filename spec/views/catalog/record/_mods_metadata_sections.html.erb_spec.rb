require "spec_helper"

describe "catalog/record/_mods_metadata_sections.html.erb" do
  include ModsFixtures

  describe "Metadata sections all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }
    before do
      assign(:document, document)
      render
    end

    it "should display correct sections" do
      expect(rendered).to have_css("h2", text: "Abstract/Contents")
      expect(rendered).to have_css("h2", text: "Subjects")
      expect(rendered).to have_css("h2", text: "Bibliographic information")
      expect(rendered).to have_css("h2", text: "Access conditions")
    end

    it "should have side nav content handles" do
      expect(rendered).to have_css(".section#abstract-contents")
      expect(rendered).to have_css(".section#subjects")
      expect(rendered).to have_css(".section#bibliography-info")
      expect(rendered).to have_css(".section#access-conditions")
    end

    it "should render side nav content" do
      expect(rendered).to have_css("ul.record-side-nav")

      expect(rendered).to have_css(".record-side-nav button i.fa.fa-arrow-up")
      expect(rendered).to have_css(".record-side-nav button i.fa.fa-arrow-down")

      expect(rendered).to have_css(".record-side-nav button.abstract-contents")
      expect(rendered).to have_css(".record-side-nav button.subjects")
      expect(rendered).to have_css(".record-side-nav button.bibliography-info")
      expect(rendered).to have_css(".record-side-nav button.access-conditions")
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
