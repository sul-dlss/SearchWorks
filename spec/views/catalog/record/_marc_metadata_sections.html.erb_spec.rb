require 'rails_helper'

RSpec.describe "catalog/record/_marc_metadata_sections" do
  include MarcMetadataFixtures

  describe "Metadata sections all available" do
    let(:document) { SolrDocument.new(marc_json_struct: marc_sections_fixture, author_struct: [{ creator: [{ link: '...', search: '...' }] }], marc_links_struct: [{ finding_aid: true }]) }

    before do
      assign(:document, document)
      render
    end

    it "should display correct sections" do
      expect(rendered).to have_css('h3', text: "Contributors")
      expect(rendered).to have_css('h3', text: "Contents/Summary")
      expect(rendered).to have_css('h3', text: "Bibliographic information")
    end

    it "should have side nav content handles" do
      expect(rendered).to have_css(".section#contributors")
      expect(rendered).to have_css(".section#contents-summary")
      expect(rendered).to have_css(".section#bibliography-info")
    end

    it "should render side nav content" do
      expect(rendered).to have_css("ul.side-nav-minimap")

      expect(rendered).to have_css(".side-nav-minimap button i.fa.fa-arrow-up")
      expect(rendered).to have_css(".side-nav-minimap button i.fa.fa-arrow-down")

      expect(rendered).to have_css(".side-nav-minimap button.contributors")
      expect(rendered).to have_css(".side-nav-minimap button.contents-summary")
      expect(rendered).to have_css(".side-nav-minimap button.bibliography-info")

      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Top")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Contributors")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Summary")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Info")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Bottom")
    end
  end
end
