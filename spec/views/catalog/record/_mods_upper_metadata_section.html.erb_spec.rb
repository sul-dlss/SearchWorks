require 'rails_helper'

RSpec.describe "catalog/record/_mods_upper_metadata_section" do
  include ModsFixtures

  describe "Upper metadata available" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }

    before do
      assign(:document, document)
    end

    it "should display correct sections" do
      render
      expect(rendered).to have_css("dt", count: 3)
      expect(rendered).to have_css("dd", count: 3)
    end
  end

  describe "Metadata sections none available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    before do
      assign(:document, document)
    end

    it "should display correct sections" do
      render
      expect(rendered).to have_no_css("dt")
      expect(rendered).to have_no_css("dd")
    end
  end
end
