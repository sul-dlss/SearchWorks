# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Browse Nearby partial result' do
  scenario 'Search results are rendered properly' do
    visit '/browse/nearby?call_number=HF1604+.G368+2024start=1&view=gallery'
    expect(page).to have_css('div.callnumber-bar', text: '630.654 .I39M V.3:NO.3')

    expect(page).to have_css('.gallery-document a[tabindex="-1"] .fake-cover .fake-cover-text', text: 'The gases of swamp rice soils ...')

    expect(page).to have_css('.gallery-document h3.index_title', text: 'The gases of swamp rice soils ...')
    expect(page).to have_css('.gallery-document button.btn-preview', text: 'Preview')
    expect(page).to have_css('form.bookmark-toggle label.toggle-bookmark', text: 'Select')
    expect(page).to have_css("div[data-doc-id='1'] label.toggle-bookmark input[type='checkbox']")
  end
end
