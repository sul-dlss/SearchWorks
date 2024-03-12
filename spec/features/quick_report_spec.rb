# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Quick report form (js)', :js do
  before do
    visit root_path
  end

  scenario 'Quick report should only be available on show page' do
    click_link 'Feedback'
    expect(page).to have_no_css('button.btn-quick-report')
    visit solr_document_path('1')
    click_link 'Feedback'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end

RSpec.feature 'Quick report form (no js)' do
  before do
    visit root_path
  end

  scenario 'Quick report should only be available on show page' do
    click_link 'Feedback'
    expect(page).to have_no_css('button.btn-quick-report')
    visit solr_document_path('1')
    click_link 'Feedback'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end
