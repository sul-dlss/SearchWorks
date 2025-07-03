# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Quick report form (js)', :js do
  before do
    visit solr_document_path('1')
  end

  scenario 'Quick report is available on show page' do
    visit solr_document_path('1')
    click_link 'Feedback'
    pending 'Needs implementation after new feedback modal in separate issue'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    pending 'Needs implementation after new feedback modal in separate issue'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end

RSpec.feature 'Quick report form (no js)' do
  before do
    visit solr_document_path('1')
  end

  scenario 'Quick report is available on show page' do
    pending 'SW4.0 redesign pending.'
    click_link 'Feedback'
    pending 'Needs implementation after new feedback modal in separate issue'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    pending 'Needs implementation after new feedback modal in separate issue'
    expect(page).to have_css('div.alert-success', text: 'Thank you! Your feedback has been sent.')
  end
end
