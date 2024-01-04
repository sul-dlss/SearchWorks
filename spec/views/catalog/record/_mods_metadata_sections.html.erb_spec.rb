require 'rails_helper'

RSpec.describe "catalog/record/_mods_metadata_sections" do
  include ModsFixtures

  describe "Metadata sections all available" do
    let(:document) { SolrDocument.new(modsxml: mods_001) }

    before do
      assign(:document, document)
      render
    end

    it "should display correct sections" do
      expect(rendered).to have_css('h3', text: "Contributors")
      expect(rendered).to have_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_css('h3', text: "Subjects")
      expect(rendered).to have_css('h3', text: "Bibliographic information")
      expect(rendered).to have_css('h3', text: "Access conditions")
    end

    it "should have side nav content handles" do
      expect(rendered).to have_css(".section#contributors")
      expect(rendered).to have_css(".section#abstract-contents")
      expect(rendered).to have_css(".section#subjects")
      expect(rendered).to have_css(".section#bibliography-info")
      expect(rendered).to have_css(".section#access-conditions")
    end

    it "should render side nav content" do
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

  describe "Metadata sections none available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    before do
      assign(:document, document)
    end

    it "should display correct sections" do
      render
      expect(rendered).to have_no_css('h3', text: "Abstract/Contents")
      expect(rendered).to have_no_css('h3', text: "Subjects")
      expect(rendered).to have_no_css('h3', text: "Access conditions")
    end
  end
end
