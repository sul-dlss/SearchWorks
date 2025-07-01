# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'EDS Facets', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  describe 'facets with a long list' do
    it 'has pagination and sort' do
      visit articles_path q: 'frog'
      click_button 'Language'
      within '.blacklight-eds_language_facet' do
        click_link 'Browse all'
      end

      expect(page).to have_field 'A-Z Sort'

      within 'dialog' do
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        click_on "Next"
        expect(page).to have_no_link 'swedish'
        expect(page).to have_link 'slovenian'

        click_on "Previous"
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        # Normally we'd use this code, but the <label> is intercepting it due to bootstrap btn-check style
        # choose "A-Z Sort"
        page.execute_script('document.querySelector("#alpha").click()')
        expect(page).to have_link 'afrikaans'
        expect(page).to have_no_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        # Normally we'd use this code, but the <label> is intercepting it due to bootstrap btn-check style
        # choose "Numerical Sort"
        page.execute_script('document.querySelector("#num").click()')
        expect(page).to have_no_link 'afrikaans'
        expect(page).to have_link 'swedish'
        expect(page).to have_no_link 'slovenian'

        click_on 'Close'
      end

      expect(page).to have_no_css 'dialog'
    end
  end
end
