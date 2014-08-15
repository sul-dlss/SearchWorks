require "spec_helper"

describe "catalog/record/_mods_upper_metadata_items.html.erb" do
  include ModsFixtures

  describe "Object upper metadata items" do
    let(:document) { SolrDocument.new(modsxml: mods_everything) }
    before do
      assign(:document, document)
    end
    it "should display name" do
      render
      expect(rendered).to have_css("dt", text: "Author/Creator")
      expect(rendered).to have_css("dd", text: "J. Smith")
    end
    it "should display description" do
      render
      expect(rendered).to have_css("dt", text: "Condition")
      expect(rendered).to have_css("dd", text: "amazing")
    end
  end
end
