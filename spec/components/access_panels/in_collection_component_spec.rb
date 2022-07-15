require "spec_helper"

RSpec.describe AccessPanels::InCollectionComponent, type: :component do
  describe 'merged records w/o collection members' do
    let(:document) { SolrDocument.new(id: '1') }
    let(:parent) { SolrDocument.new(id: '2') }

    before do
      allow(document).to receive(:parent_collections).and_return([parent])
      allow(document).to receive(:is_a_collection_member?).and_return(true)

      render_inline(described_class.new(document: document))
    end

    it 'renders the block properly if the collection members are not present' do
      expect(page).to have_css("h3", text: 'Item belongs to a collection')
      expect(page).not_to have_content("Digital content")
    end
  end
end
