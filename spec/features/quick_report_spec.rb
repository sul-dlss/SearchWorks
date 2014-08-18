require 'spec_helper'

feature 'Quick report form (js)', js: true do
  before do
    visit root_path
  end
  scenario 'Quick report should only be available on show page' do
    pending('Passes locally, not on Travis.') if ENV['CI']
    click_link 'Feedback'
    expect(page).to_not have_css('button.btn-quick-report')
    visit catalog_path('1')
    click_link 'Feedback'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end

feature 'Quick report form (no js)' do
  before do
    visit root_path
  end
  scenario 'Quick report should only be available on show page' do
    click_link 'Feedback'
    expect(page).to_not have_css('button.btn-quick-report')
    visit catalog_path('1')
    click_link 'Feedback'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end
