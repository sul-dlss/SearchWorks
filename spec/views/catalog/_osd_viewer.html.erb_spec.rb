require "spec_helper"

describe "catalog/_osd_viewer.html.erb" do
  before do
    view.stub(:openseadragon_picture_tag).and_return('<osd-provided-markup />')
  end
  describe "single image" do
    before do
      assign(:document,
        SolrDocument.new(
          druid: "12345",
          file_id: ['image-id1']
        )
      )
      render
    end
    it "should not include the paging section" do
      expect(rendered).to_not have_css('.paging')
    end
    it 'should include the PURL' do
      expect(rendered).to have_css('.purl-link a', text: 'purl.stanford.edu/12345')
    end
  end
  describe "multiple images" do
    before do
      assign(:document,
        SolrDocument.new(
          druid: "12345",
          file_id: ['image-id1', 'image-id2']
        )
      )
      render
    end
    it "should include the paging section" do
      expect(rendered).to have_css('.paging')
    end
    it 'should include the PURL' do
      expect(rendered).to have_css('.purl-link a', text: 'purl.stanford.edu/12345')
    end
  end
end