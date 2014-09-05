require "spec_helper"

describe "catalog/thumbnails/_merged_file_collection_thumbnail.html.erb" do
  describe "fake covers" do
    before do
      view.stub(:document).and_return(SolrDocument.new(id: '1234', title_display: "Title"))
    end
    it "should be included on the gallery view" do
      view.stub(:document_index_view_type).and_return(:gallery)
      render
      expect(rendered).to have_css('.fake-cover', text: "Title")
    end
    it "should not be included on other views" do
      view.stub(:document_index_view_type).and_return(:list)
      render
      expect(rendered).to_not have_css('.fake-cover')
    end
  end
end
