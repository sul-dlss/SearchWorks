# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomepageSearchComponent, type: :component do
  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
  end

  it 'includes Semantic in the homepage search-field dropdown' do
    render_inline(described_class.new(url: '/catalog', params: {}))

    expect(page).to have_css('select[name="search_field"] option[value="semantic"]', text: 'Semantic')
  end
end
