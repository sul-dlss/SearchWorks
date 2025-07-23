# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bound with children', :js do
  describe 'visible on the avaliability modal' do
    it 'has a modal' do
      visit solr_document_path('5488000')
      all(:link, 'See items').last.click

      expect(page).to have_css(".modal")
      expect(page.all('td.bound-with-title').size).to be 5
    end

    it 'has a clickable show more button' do
      visit bound_with_children_solr_document_path('5488000', item_id: 'f947bd93-a1eb-5613-8745-1063f948c461')

      expect(page).to have_button('Show more')
      click_button 'Show more'

      expect(page).to have_button("Show less")
      expect(page.all('li div.bound-with-title').size).to be 5
    end

    it 'still has a show more button' do
      visit bound_with_children_solr_document_path('5488000', item_id: '1193e6b3-3bfc-5c51-b1ac-7ef347cdc46f')

      expect(page).to have_button('Show more')
      click_button 'Show more'

      expect(page).to have_button("Show less")
      expect(page.all('li div.bound-with-title').size).to be 1
    end
  end
end
