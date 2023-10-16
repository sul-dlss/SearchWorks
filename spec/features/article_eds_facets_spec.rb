# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'EDS Facets', js: true do
  describe 'OR facets' do
    context 'Source Type' do
      scenario 'shows warning message when 1 field is selected' do
        stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
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
          expect(page).not_to have_css('.facet_limit-active')
          expect(page).not_to have_css('.alert-warning')
        end
      end
    end

    context 'Database' do
      scenario 'shows warning message when 1 field is selected' do
        stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
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
          expect(page).not_to have_css('.facet_limit-active')
          expect(page).not_to have_css('.alert-warning')
        end
      end
    end
  end
end
