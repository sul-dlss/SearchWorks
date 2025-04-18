# frozen_string_literal: true

require "rails_helper"

RSpec.describe Articles::Document::BookmarkComponent, type: :component do
  before do
    vc_test_controller.instance_variable_set(:@document, document)
    allow(vc_test_controller).to receive(:current_or_guest_user).and_return(User.new)
    render_inline(described_class.new(document:, action:))
  end

  let(:document) { SolrDocument.new(id: '1') }
  let(:action) {
    instance_double(Blacklight::Configuration::ToolConfig, name: :bookmark, fetch: 'bookmarkLink')
  }

  it 'has hidden fields' do
    expect(page).to have_field('bookmarks[][document_id]', type: :hidden)
    expect(page).to have_field('bookmarks[][record_type]', type: :hidden)
    expect(page).to have_field('bookmarks[][document_type]', type: :hidden)
  end
end
