# frozen_string_literal: true

require "rails_helper"

RSpec.describe Document::TrackingBookmarkComponent, type: :component do
  before do
    vc_test_controller.instance_variable_set(:@document, document)
    allow(vc_test_controller).to receive(:current_or_guest_user).and_return(User.new)
    render_inline(described_class.new(document:, action:))
  end

  let(:document) { SolrDocument.new(id: '1') }
  let(:action) { instance_double(Blacklight::Configuration::ToolConfig, name: :bookmark, fetch: 'bookmarkLink') }

  it 'gathers analytics' do
    expect(page).to have_css '[data-controller="analytics"]'
    expect(page).to have_css 'button[data-action^="click->analytics#trackBookmark"]'
  end
end
