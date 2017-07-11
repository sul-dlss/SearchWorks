# frozen_string_literal: true

require 'spec_helper'

describe 'Responsive subnavbar (gray banner)', js: true, feature: true do
  scenario 'collapses menu options in mobile view' do
    visit root_path
    expect(page).to have_css('a', text: /Library services/)
    expect(page).to have_css('a', text: /Advanced search/)
    expect(page).to have_css('a', text: /Course reserves/)
    expect(page).to have_css('a', text: /Selections/)

    page.driver.resize('760', '480')
    expect(page).to have_css('button', text: /Menu/)
  end
end
