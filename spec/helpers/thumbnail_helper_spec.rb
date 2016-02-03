require "spec_helper"

describe ThumbnailHelper do
  describe "#render_cover_image" do
    let(:document) { SolrDocument.new }
    let(:numbers) { {isbn: '', oclc: '', lccn: ''} }
    let(:expected_locals) { {document: document, css_class: ''}.merge(numbers) }
    before do
      allow(helper).to receive(:book_ids).and_return(numbers)
    end
    it "should return nothing when the document does not have an associated thumbnail parital" do
      expect(helper.render_cover_image(document)).to be_nil
    end
    it "should render the appropriate partial for a document's display type" do
      allow(document).to receive(:display_type).and_return('marc')
      expect(helper).to receive(:render).with({partial: 'catalog/thumbnails/marc_thumbnail', locals: expected_locals})
      helper.render_cover_image(document)
    end
  end
end
