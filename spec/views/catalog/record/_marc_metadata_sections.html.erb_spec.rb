require "spec_helper"

describe "catalog/record/_marc_metadata_sections.html.erb" do
  include MarcMetadataFixtures

  describe "Metadata sections all available" do
    let(:document) { SolrDocument.new(marcxml: marc_sections_fixture) }

    before do
      assign(:document, document)
      render
    end

    it "should display correct sections" do
      expect(rendered).to have_css("h2", text: "Contents/Summary")
      expect(rendered).to have_css("h2", text: "Bibliographic information")
    end

    it "should have side nav content handles" do
      expect(rendered).to have_css(".section#contents-summary")
      expect(rendered).to have_css(".section#bibliography-info")
    end

    it "should render side nav content" do
      expect(rendered).to have_css("ul.record-side-nav")

      expect(rendered).to have_css(".record-side-nav button i.fa.fa-arrow-up")
      expect(rendered).to have_css(".record-side-nav button i.fa.fa-arrow-down")

      expect(rendered).to have_css(".record-side-nav button.contents-summary")
      expect(rendered).to have_css(".record-side-nav button.bibliography-info")
    end
  end

end
