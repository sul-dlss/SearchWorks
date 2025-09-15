# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Autocomplete" do
  context "when on the home page", :js do
    before do
      visit root_path
    end
    scenario "has autocomplete src set when user select author/contributor", :js do
      expect(page).to have_css('.input-group[data-controller="auto-complete"]')
      expect(page).to have_css('auto-complete[data-auto-complete-src="/catalog/suggest"]')
      expect(page).to_not have_css('auto-complete[src="/catalog/suggest"]')

      select('Author/Contributor', from: 'search_field')
      expect(page).to have_css('auto-complete[src="/catalog/suggest"]')
    end
  end

  context "when on the search results page", :js do
    before do
      visit search_catalog_path
    end

    scenario "has autocomplete src set when user select author/contributor", :js do
      expect(page).to have_css('.input-group[data-controller="auto-complete"]')
      expect(page).to have_css('auto-complete[data-auto-complete-src="/catalog/suggest"]')
      expect(page).to_not have_css('auto-complete[src="/catalog/suggest"]')

      select('Author/Contributor', from: 'search_field')
      expect(page).to have_css('auto-complete[src="/catalog/suggest"]')
    end
  end

  context "when on the search results page with author/contributor pre-selected", :js do
    before do
      visit search_catalog_path('search_field': 'search_author')
    end

    scenario "has autocomplete src set with pre-selected author/contributor", :js do
      expect(page).to have_css('auto-complete[src="/catalog/suggest"]')
    end
  end
end