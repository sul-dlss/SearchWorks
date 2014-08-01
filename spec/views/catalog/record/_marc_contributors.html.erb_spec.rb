require "spec_helper"

describe "catalog/record/_marc_contributors.html.erb" do
  include MarcMetadataFixtures

  describe "Contributors section" do
    before do
      assign(:document, SolrDocument.new(marcxml: contributor_fixture))
      render
    end
    it "should display secondary authors" do
      expect(rendered).to have_css("dt", text: "Contributor")
      expect(rendered).to have_css('dd', count: 3)

      expect(rendered).to have_css("dd a", text: "Contributor1")

      expect(rendered).to have_css("dd a", text: "Contributor2")
      expect(rendered).to have_css("dd", text: /Performer/, count: 2)

      expect(rendered).to have_css("dd a", text: "Contributor3")
      expect(rendered).to have_css("dd", text: /Actor/)
    end
  end
end
