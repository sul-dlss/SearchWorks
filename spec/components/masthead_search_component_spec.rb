# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MastheadSearchComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
  end

  it 'includes and retains Semantic in the results-page search-field dropdown' do
    render_inline(described_class.new(url: '/catalog', params: { search_field: 'semantic', q: 'frogs' }))

    expect(page).to have_css('select[name="search_field"] option[value="semantic"][selected]', text: 'Semantic')
  end
end
