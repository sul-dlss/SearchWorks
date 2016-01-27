require "spec_helper"

describe "catalog/thumbnails/_image_collection_thumbnail.html.erb" do
  describe "fake covers" do
    let(:document) { SolrDocument.new(id: '1234', title_display: "Title") }
    before do
      allow(view).to receive(:document).and_return(document)
    end
    it "should be included on the gallery view" do
      expect(document).to receive(:collection_members).at_least(:once).and_return([
        SolrDocument.new(display_type: ['image'], file_id: ['123', '321'])
      ])
      allow(view).to receive(:document_index_view_type).and_return(:gallery)
      render
      expect(rendered).to have_css('img.stacks-image')
    end
    it "should not be included on other views" do
      allow(view).to receive(:document_index_view_type).and_return(:list)
      render
      expect(rendered).to_not have_css('img.stacks-image')
    end
  end
end
