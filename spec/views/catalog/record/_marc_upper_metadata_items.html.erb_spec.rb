require "spec_helper"

describe "catalog/record/_marc_upper_metadata_items.html.erb" do
  include MarcMetadataFixtures
  describe "characteristics" do
    before do
      assign(:document, SolrDocument.new(marcxml: marc_characteristics_fixture))
      render
    end
    it "should display the characteristics with labels" do
      expect(rendered).to have_css('dt', text: 'Sound')
      expect(rendered).to have_css('dd', text: 'digital; optical; surround; stereo; Dolby.')
      expect(rendered).to have_css('dt', text: 'Video')
      expect(rendered).to have_css('dd', text: 'NTSC.')
      expect(rendered).to have_css('dt', text: 'Digital')
      expect(rendered).to have_css('dd', text: 'video file; DVD video; Region 1.')
    end
  end
  describe "series" do
    before do
      assign(:document, SolrDocument.new(marcxml: marc_multi_series_fixture))
      render
    end
    it "link to series" do
      expect(rendered).to have_css('dt', text: "Series")
      expect(rendered).to have_css('dd a', text: "440 $a")
      expect(rendered).to have_css('dd a', text: "Name SubZ")
    end
  end
end
