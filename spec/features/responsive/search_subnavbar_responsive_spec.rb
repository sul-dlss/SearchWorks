# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Responsive subnavbar (gray banner)', feature: true, js: true, page_width: 700, responsive: true do
  scenario 'collapses menu options in mobile view' do
    visit root_path

    expect(page).to have_css('a', text: /Help/, visible: false)
    expect(page).to have_css('a', text: /Advanced search/, visible: false)
    expect(page).to have_css('a', text: /Course reserves/, visible: false)
    expect(page).to have_css('a', text: /Selections/, visible: false)

    expect(page).to have_css('button', text: /Menu/, visible: true)
  end
end
