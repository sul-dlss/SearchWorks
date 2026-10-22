# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Database views", :feature, :js do
  context 'with no search parameters on' do
    before do
      visit databases_path
    end

    it 'displays database homepage view with A-Z list' do
      expect(page).to have_css('h2', text: 'Database topics')
      expect(page).to have_css('h2', text: 'A')
      expect(page).to have_link('American History (1)', href: '/databases?f%5Bdb_az_subject%5D%5B%5D=American+History')
    end

    it 'renders Popular database aside and does not render drawer button on MD screens', :responsive, page_width: 768 do
      expect(page).to have_css('dialog.popular-databases')
      expect(page).to have_link('scholar.google.com', href: 'https://scholar.google.com/')
      expect(page).to have_no_css('[data-bs-toggle="drawer"]')
    end

    it 'renders drawer features under MD breakpoint', :responsive, page_width: 767 do
      expect(page).to have_no_css('dialog.popular-databases')
      expect(page).to have_css('[data-bs-toggle="drawer"]')
      click_button('Popular databases')
      expect(page).to have_css('dialog.popular-databases')
    end
  end

  context 'with a facet parameter' do
    before do
      visit databases_path(f: { db_az_subject: ['American History'] })
    end

    it 'displays intended facet areas' do
      expect(page).to have_css('#facets-other-filters')
      expect(page).to have_no_css('#facets-top-filters')
      expect(page).to have_css('.selected', text: 'American History')
    end

    it 'hides the facet expand button' do
      expect(page).to have_no_css('[data-facet-list-target="button"]')
    end

    it 'routes back to the database homepage when the facet is removed' do
      click_link('Remove constraint Database topic: American History')
      expect(page).to have_css('h2', text: 'Database topics')
    end
  end

  context 'with a search parameter' do
    before do
      visit databases_path(q: 'art')
    end

    it 'supresses the Mini bento component' do
      expect(page).to have_no_css('#alternate-catalog-drawer')
    end

    it 'displays intended facet areas' do
      expect(page).to have_css('#facets-other-filters')
      expect(page).to have_no_css('#facets-top-filters')
      expect(page).to have_no_css('.selected')
    end

    it 'routes back to the database homepage when param is removed' do
      click_link('Remove constraint art')
      expect(page).to have_css('h2', text: 'Database topics')
    end

    it 'does not render drawer button on 2XL screens', :responsive, page_width: 1536 do
      expect(page).to have_no_css('[data-bs-toggle="drawer"]')
    end

    it 'renders the popular databases drawer button under 2XL breakpoint', :responsive, page_width: 1535 do
      expect(page).to have_no_css('dialog.popular-databases')
      expect(page).to have_css('[data-bs-toggle="drawer"]')
      click_button('Popular databases')
      expect(page).to have_css('dialog.popular-databases')
    end
  end
end
