# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bound with children', :js do
  describe 'visible on the record page' do
    it 'has a clickable see all modal' do
      visit bound_with_children_solr_document_path('5488000', item_id: 'f947bd93-a1eb-5613-8745-1063f948c461')

      expect(page).to have_link("See all items bound with 630.654 .I39M")
      click_link 'See all items bound with 630.654 .I39M'

      expect(page).to have_css(".modal")
      expect(page.all('td.bound-with-title').size).to be 5
    end

    it 'does not need a modal' do
      visit bound_with_children_solr_document_path('5488000', item_id: '1193e6b3-3bfc-5c51-b1ac-7ef347cdc46f')

      expect(page.all('li div.bound-with-title').size).to be 1
      expect(page).to have_no_link '630.654 .I39M V.4:NO.1,4'
      expect(page).to have_no_css(".modal")
    end
  end
end
