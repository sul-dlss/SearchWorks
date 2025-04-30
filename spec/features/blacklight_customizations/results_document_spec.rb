# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Results Document Metadata' do
  it 'has the stacks image for objects with image behavior' do
    visit root_path
    fill_in 'search for', with: 'Image Item3' # 35.yml in fixtures
    click_button 'search'

    within 'article.document' do
      within('.document-thumbnail') do
        expect(page).to have_css('img.stacks-image')
        expect(page).to have_css('img.stacks-image[alt=""]')
        expect(page).to have_link 'IIIF Drag-n-drop'
      end
    end
  end
end
