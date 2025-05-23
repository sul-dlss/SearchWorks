# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'EDS Facets', :js do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  describe 'facets with a long list' do
    it 'has pagination and sort' do
      visit articles_path q: 'frog'

      expect(page).to have_css('.blacklight-eds_language_facet .facet-values', visible: :hidden)
      click_button 'Language'
      within '.blacklight-eds_language_facet' do
        click_link 'more'
      end
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

  describe 'OR facets' do
    context 'Source Type' do
      scenario 'shows warning message when 1 field is selected' do
        visit articles_path f: {
          eds_search_limiters_facet: ['Stanford has it'],
          eds_publication_type_facet: ['Academic journals']
        }
        within '.blacklight-eds_publication_type_facet' do
          expect(page).to have_css('.alert-warning')
          click_link 'remove'
        end
        click_button 'Source type'
        within '.blacklight-eds_publication_type_facet' do
          expect(page).to have_no_css('.facet_limit-active')
          expect(page).to have_no_css('.alert-warning')
        end
      end
    end

    context 'Database' do
      scenario 'shows warning message when 1 field is selected' do
        visit articles_path f: {
          eds_search_limiters_facet: ['Stanford has it'],
          eds_content_provider_facet: ['Journal provider']
        }
        within '.blacklight-eds_content_provider_facet' do
          expect(page).to have_css('.alert-warning')
          click_link 'remove'
        end
        click_button 'Database'
        within '.blacklight-eds_content_provider_facet' do
          expect(page).to have_no_css('.facet_limit-active')
          expect(page).to have_no_css('.alert-warning')
        end
      end
    end
  end
end
