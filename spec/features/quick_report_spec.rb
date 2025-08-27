# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Quick report form', :js do
  scenario 'Quick report is available on show page' do
    visit solr_document_path('in00000053236')
    click_link 'Feedback'
    expect(page).to have_css('button.btn-quick-report')
    click_button 'Report wrong cover image'
    expect(page).to have_css('.toast', text: 'Your feedback has been sent.')
  end
end
