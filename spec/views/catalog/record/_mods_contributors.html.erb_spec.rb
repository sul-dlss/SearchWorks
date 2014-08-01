require "spec_helper"

describe "catalog/record/_mods_contributors.html.erb" do
  include ModsFixtures

  describe "Contributors section" do
    before do
      assign(:document, SolrDocument.new(modsxml: mods_everything))
      render
    end
    it "should display secondary authors" do
      expect(rendered).to have_css("dt", text: "Contributor")
      expect(rendered).to have_css('dd', count: 1)
      expect(rendered).to have_css("dd a", text: "B. Smith")
      expect(rendered).to have_css("dd", text: /\(Producer\)/)
    end
  end
end
