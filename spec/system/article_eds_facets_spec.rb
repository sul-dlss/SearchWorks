# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'EDS Facets', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  describe 'facets with a long list' do
    it 'has pagination and sort' do # rubocop:disable RSpec/ExampleLength
      skip if ENV['CI'] == 'true' # Fails on CI, but works locally
      visit articles_path q: 'frog'
      click_button 'Show all filters'
      click_button 'Language'
      within '.blacklight-eds_language_facet' do
        click_link 'Browse all'
      end

      within 'dialog' do
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        within '.modal-header .facet-pagination' do
          click_on "Next"
        end
        expect(page).to have_no_link 'swedish'
        expect(page).to have_link 'slovenian'

        within '.modal-header .facet-pagination' do
          click_on "Previous"
        end
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        click_button 'Sort by number of matches'
        click_button 'A-Z'
        expect(page).to have_link 'afrikaans'
        expect(page).to have_no_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        click_button 'Sort by A-Z'
        click_button 'Number of matches'
        expect(page).to have_no_link 'afrikaans'
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        click_on 'Close'
      end

      expect(page).to have_no_css 'dialog'
    end
  end
end
