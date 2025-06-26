# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "MARC Metadata in search results" do
  describe "author/creator" do
    before do
      visit root_path
      fill_in 'q', with: '14'
      click_button 'search'
    end

    it "links the author/creator, corporate author, and meeting" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Arbitrary, Stewart.')
        end
      end
    end
  end

  describe "corporate author" do
    before do
      visit root_path
      fill_in 'q', with: '15'
      click_button 'search'
    end

    skip "should link the corporate author" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Scientific Council for Africa South of the Sahara.')
        end
      end
    end
  end

  describe "meeting author" do
    before do
      visit root_path
      fill_in 'q', with: '16'
      click_button 'search'
    end

    skip "should link the meeting author" do
      within(first('.document')) do
        within('ul.document-metadata') do
          expect(page).to have_css('li a', text: 'Most Excellent Meeting')
        end
      end
    end
  end
end
