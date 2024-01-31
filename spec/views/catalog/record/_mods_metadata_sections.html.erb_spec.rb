require 'rails_helper'

RSpec.describe "catalog/record/_mods_metadata_sections" do
  include ModsFixtures

  before do
    render 'catalog/record/mods_metadata_sections', document:
  end

  context "when metadata sections are all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    it "displays correct sections" do
      expect(rendered).to have_css('h3', text: "Contributors")
      expect(rendered).to have_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_css('h3', text: "Subjects")
      expect(rendered).to have_css('h3', text: "Bibliographic information")
      expect(rendered).to have_css('h3', text: "Access conditions")
    end

    it "has side nav content handles" do
      expect(rendered).to have_css(".section#contributors")
      expect(rendered).to have_css(".section#abstract-contents")
      expect(rendered).to have_css(".section#subjects")
      expect(rendered).to have_css(".section#bibliography-info")
      expect(rendered).to have_css(".section#access-conditions")
    end

    it "renders side nav content" do
      expect(rendered).to have_css("ul.side-nav-minimap")

      expect(rendered).to have_css(".side-nav-minimap button i.fa.fa-arrow-up")
      expect(rendered).to have_css(".side-nav-minimap button i.fa.fa-arrow-down")

      expect(rendered).to have_css(".side-nav-minimap button.contributors")
      expect(rendered).to have_css(".side-nav-minimap button.abstract-contents")
      expect(rendered).to have_css(".side-nav-minimap button.subjects")
      expect(rendered).to have_css(".side-nav-minimap button.bibliography-info")
      expect(rendered).to have_css(".side-nav-minimap button.access-conditions")

      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Top")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Contents")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Subjects")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Info")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Access")
      expect(rendered).to have_css(".side-nav-minimap button span.nav-label", text: "Bottom")
    end
  end

  context "when no metadata sections are available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    it "displays correct sections" do
      expect(rendered).to have_no_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_no_css('h3', text: "Subjects")
      expect(rendered).to have_no_css('h3', text: "Access conditions")
    end
  end
end
