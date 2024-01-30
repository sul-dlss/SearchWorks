require 'rails_helper'

RSpec.describe "catalog/record/_mods_upper_metadata_section" do
  include ModsFixtures

  before do
    render 'catalog/record/mods_upper_metadata_section', document:
  end

  describe "Upper metadata available" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }

    it "displays correct sections" do
      expect(rendered).to have_css("dt", count: 3)
      expect(rendered).to have_css("dd", count: 3)
    end
  end

  describe "Metadata sections none available" do
    let(:document) { SolrDocument.new(modsxml: mods_only_title) }

    it "displays correct sections" do
      expect(rendered).to have_no_css("dt")
      expect(rendered).to have_no_css("dd")
    end
  end
end
