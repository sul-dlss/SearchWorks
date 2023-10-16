require 'rails_helper'

RSpec.describe "catalog/record/_mods_upper_metadata_items" do
  include ModsFixtures

  describe "Object upper metadata items" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }

    before do
      assign(:document, document)
    end

    it "should display type" do
      render
      expect(rendered).to have_css("dt", text: "Type of resource")
      expect(rendered).to have_css("dd", text: "still image")
    end
    it "should display imprint" do
      render
      expect(rendered).to have_css("dt", text: "Imprint")
      expect(rendered).to have_css("dd", text: "copyright 2014")
    end
    skip "should display language" do
      # render
      # expect(rendered).to have_css("div.section-uppermetadata dt", text: "Lang")
      # expect(rendered).to have_css("div.section-uppermetadata dd", text: "Esperanza")
    end
    it "should display description" do
      render
      expect(rendered).to have_css("dt", text: "Condition")
      expect(rendered).to have_css("dd", text: "amazing")
    end
  end
end
