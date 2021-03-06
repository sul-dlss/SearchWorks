# frozen_string_literal: true

require 'spec_helper'

describe 'Responsive subnavbar (gray banner)', js: true, feature: true, responsive: true, page_width: 700 do
  scenario 'collapses menu options in mobile view' do
    visit root_path

    expect(page).to have_css('a', text: /Help/, visible: false)
    expect(page).to have_css('a', text: /Advanced search/, visible: false)
    expect(page).to have_css('a', text: /Course reserves/, visible: false)
    expect(page).to have_css('a', text: /Selections/, visible: false)

    expect(page).to have_css('button', text: /Menu/, visible: true)
  end
end
