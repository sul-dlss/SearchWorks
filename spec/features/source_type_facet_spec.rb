# frozen_string_literal: true

require 'spec_helper'

feature 'Source Type Facet', js: true do
  context 'articles+ search' do
    scenario 'shows warning message when 1 field is selected' do
      stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
      visit articles_path f: {
        eds_search_limiters_facet: ['Stanford has it'],
        eds_publication_type_facet: ['Academic journals']
      }
      within '.panel.blacklight-eds_publication_type_facet' do
        expect(page).to have_css('.alert-warning')
        click_link 'remove'
      end
      page.find('h3.panel-title', text: 'Source type').click
      within '.panel.blacklight-eds_publication_type_facet' do
        expect(page).not_to have_css('.facet_limit-active')
        expect(page).not_to have_css('.alert-warning')
      end
    end
  end
end
