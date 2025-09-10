# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Search types" do
  scenario "should include our custom types" do
    visit root_path

    within('#search_field') do
      expect(page).to have_css('option[value="search"]',        text: 'All fields')
      expect(page).to have_css('option[value="search_title"]',  text: 'Title')
      expect(page).to have_css('option[value="search_author"]', text: 'Author/Contributor')
      expect(page).to have_css('option[value="subject_terms"]', text: 'Subject')
      expect(page).to have_css('option[value="call_number"]',   text: 'Call number')
      expect(page).to have_css('option[value="search_series"]', text: 'Series')
    end
  end

  it 'has different types for article search' do
    visit articles_path

    within('#search_field') do
      expect(page).to have_css('option[value="search"]',  text: 'All fields')
      expect(page).to have_css('option[value="author"]',  text: 'Author')
      expect(page).to have_css('option[value="title"]',   text: 'Title')
      expect(page).to have_css('option[value="subject"]', text: 'Subject')
      expect(page).to have_css('option[value="source"]',  text: 'Journal/Source')
    end
  end

  scenario 'switching search modes from the home page', :js do
    visit root_path

    aggregate_failures('has catalog search types') do
      within('#search_field') do
        expect(page).to have_css('option[value="search"]',        text: 'All fields')
        expect(page).to have_css('option[value="search_title"]',  text: 'Title')
        expect(page).to have_css('option[value="search_author"]', text: 'Author/Contributor')
        expect(page).to have_css('option[value="subject_terms"]', text: 'Subject')
        expect(page).to have_css('option[value="call_number"]',   text: 'Call number')
        expect(page).to have_css('option[value="search_series"]', text: 'Series')
      end
    end

    choose 'Articles+'

    aggregate_failures('has article search types') do
      within('#search_field') do
        expect(page).to have_css('option[value="search"]',  text: 'All fields')
        expect(page).to have_css('option[value="author"]',  text: 'Author')
        expect(page).to have_css('option[value="title"]',   text: 'Title')
        expect(page).to have_css('option[value="subject"]', text: 'Subject')
        expect(page).to have_css('option[value="source"]',  text: 'Journal/Source')
      end
    end
  end
end
