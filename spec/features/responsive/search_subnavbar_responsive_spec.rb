# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Responsive subnavbar (gray banner)', :feature, :js, :responsive, page_width: 700 do
  scenario 'collapses menu options in mobile view' do
    visit solr_document_path('1')

    expect(page).to have_css('a', text: /Help/, visible: false)
    expect(page).to have_css('a', text: /Featured resources/, visible: false)
    expect(page).to have_css('a', text: /Bookmarks/, visible: false)
    expect(page).to have_css('a', text: /Login/, visible: false)

    expect(page).to have_css('button[aria-label="Toggle navigation"]', visible: true)
  end
end
