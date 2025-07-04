# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "MHLD", :feature do
  describe "record view" do
    it "is present in the location access panel" do
      visit solr_document_path('10')

      within('[data-hours-route="/hours/ENG"]') do
        expect(page).to have_css('.location-name', text: 'Periodicals')
        expect(page).to have_css('.mhld', text: 'public note2')
        expect(page).to have_css('.mhld.note-highlight', text: 'Latest: latest received2')
        expect(page).to have_css('.mhld', text: 'Library has: library has2')
      end
      within('[data-hours-route="/hours/GREEN"]') do
        expect(page).to have_css('.location-name', text: 'Stacks')
        expect(page).to have_css('.mhld', text: 'public note3')
        expect(page).to have_css('.mhld.note-highlight', text: 'Latest: latest received3')
        expect(page).to have_css('.mhld', text: 'Library has: library has3')
      end
    end
  end
end
