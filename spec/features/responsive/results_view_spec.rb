# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Responsive results view Page', :feature, :js do
  before do
    visit search_catalog_path f: { access_facet: ['Online'] }
  end

  it 'shows previous/next on large screens' do
    within('ul.pagination') do
      expect(page).to have_css('a', text: 'Previous', visible: true)
    end
  end
end
