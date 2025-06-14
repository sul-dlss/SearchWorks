# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Responsive subnavbar (gray banner)', :feature, :js, :responsive, page_width: 700 do
  scenario 'collapses menu options in mobile view' do
    visit solr_document_path('1')

    expect(page).to have_css('a', text: /Help/, visible: false)
    expect(page).to have_css('a', text: /Advanced search/, visible: false)
    expect(page).to have_css('a', text: /Course reserves/, visible: false)
    expect(page).to have_css('a', text: /Selections/, visible: false)

    expect(page).to have_css('button', text: /Menu/, visible: true)
  end
end
