# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bound with availability', :js do
  describe 'availability panel display' do
    it 'links to a modal view of the bound with children' do
      visit solr_document_path('5488000')

      expect(page).to have_text 'Bound and shelved with:'
      expect(page).to have_text 'Item is bound with other items'
      all(:link, 'See items').last.click

      expect(page).to have_css('dialog')
      within 'dialog' do
        expect(page).to have_text 'Items bound with'
        expect(page.all('td.bound-with-title').size).to be 5
      end
    end
  end

  describe 'availability modal display' do
    it 'displays the bound with parent and children' do
      visit solr_document_path('5488000')
      click_link 'Expand'

      within 'dialog' do
        expect(page).to have_text 'Bound and shelved with:'
        expect(page).to have_text 'Item is bound with other items'
      end
    end
  end

  describe 'bound with child display used in the availability modal' do
    it 'lists the bound with children via a clickable show more button' do
      visit bound_with_children_solr_document_path('5488000', item_id: 'f947bd93-a1eb-5613-8745-1063f948c461')

      click_button 'Show more'

      expect(page).to have_button 'Show less'
      expect(page).to have_text 'Item is bound with other items'
      expect(page.all('li div.bound-with-title').size).to be 5
    end

    it 'lists the correct number of bound with children for the provided item' do
      visit bound_with_children_solr_document_path('5488000', item_id: '1193e6b3-3bfc-5c51-b1ac-7ef347cdc46f')
      click_button 'Show more'

      expect(page).to have_button 'Show less'
      expect(page.all('li div.bound-with-title').size).to be 1
    end
  end
end
