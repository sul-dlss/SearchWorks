require "spec_helper"

describe "catalog/record/_marc_upper_metadata_items.html.erb" do
  include MarcMetadataFixtures
  describe "series" do
    before do
      assign(:document, SolrDocument.new(marcxml: marc_multi_series_fixture))
      render
    end
    it "link to series" do
      expect(rendered).to have_css('dt', text: "Series:")
      expect(rendered).to have_css('dd a', text: "440 $a")
      expect(rendered).to have_css('dd a', text: "Name SubZ")
    end
  end
end
