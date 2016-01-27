require "spec_helper"

describe "catalog/thumbnails/_marc_thumbnail.html.erb" do
  describe "fake covers" do
    before do
      allow(view).to receive(:css_class).and_return('')
      allow(view).to receive(:oclc).and_return('')
      allow(view).to receive(:isbn).and_return('')
      allow(view).to receive(:lccn).and_return('')
      allow(view).to receive(:document).and_return(SolrDocument.new(id: '1234', title_display: "Title"))
    end
    it "should be included on the gallery view" do
      allow(view).to receive(:document_index_view_type).and_return(:gallery)
      render
      expect(rendered).to have_css('.fake-cover', text: "Title")
    end
    it "should not be included on other views" do
      allow(view).to receive(:document_index_view_type).and_return(:list)
      render
      expect(rendered).to have_css('img.cover-image')
      expect(rendered).to_not have_css('.fake-cover')
    end
  end
end
