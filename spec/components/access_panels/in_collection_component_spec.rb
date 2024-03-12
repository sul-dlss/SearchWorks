# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::InCollectionComponent, type: :component do
  describe 'merged records w/o collection members' do
    let(:document) { SolrDocument.new(id: '1') }
    let(:parent) { SolrDocument.new(id: '2') }

    before do
      allow(document).to receive_messages(parent_collections: [parent], is_a_collection_member?: true)

      render_inline(described_class.new(document:))
    end

    it 'renders the block properly if the collection members are not present' do
      expect(page).to have_css("h3", text: 'Item belongs to a collection')
      expect(page).to have_no_content("Digital content")
    end
  end

  describe 'merged records with collection members that have encoded summaries' do
    let(:document) { SolrDocument.new(id: '1') }
    let(:parent) { SolrDocument.new(id: '2', summary_display: ['Summary &amp; Display']) }

    before do
      allow(document).to receive_messages(parent_collections: [parent])
      render_inline(described_class.new(document:))
    end

    it 'renders summary display with summary display encoded properly' do
      expect(page).to have_css("h3", text: 'Item belongs to a collection')
      expect(page).to have_css("div.card-body", text: 'Summary & Display')
      expect(page).to have_no_content("Digital content")
    end
  end
end
