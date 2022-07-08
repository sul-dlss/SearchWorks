require "spec_helper"

describe "catalog/access_panels/_in_collection" do
  describe 'merged records w/o collection members' do
    let(:document) { SolrDocument.new(id: '1') }
    let(:parent) { SolrDocument.new(id: '2') }

    before do
      allow(view).to receive(:document_presenter).and_return(OpenStruct.new(heading: "Title"))
      allow(document).to receive(:parent_collections).and_return([parent])
      allow(document).to receive(:is_a_collection_member?).and_return(true)
      assign(:document, document)
      render
    end

    it 'should render the block properly if the collection members are not present' do
      expect(rendered).to have_css("h3", text: 'Item belongs to a collection')
      expect(rendered).not_to have_content("Digital content")
    end
  end
end
