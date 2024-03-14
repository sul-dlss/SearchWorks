# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Facets' do
  context 'Library Specific Location Facets' do
    context 'Art & Architecture' do
      it 'renders the location facet when Art is selected' do
        visit root_path

        click_link 'Art & Architecture (Bowes)'

        within('.facets') do
          expect(page).to have_css('h3', text: 'Location')
          expect(page).to have_css('a', text: 'Art Locked Stacks')
        end
      end
    end

    context 'Education (Cubberley)' do
      it 'renders the location facet when Education is selected' do
        visit root_path

        click_link 'Education (Cubberley)'

        within('.facets') do
          expect(page).to have_css('h3', text: 'Location')
          expect(page).to have_css('a', text: 'Curriculum Collection')
        end
      end
    end

    context 'other libraries' do
      it 'does not render the location facet' do
        visit root_path

        click_link 'Green'

        within('.facets') do
          expect(page).to have_no_css('h3', text: 'Location')
        end
      end
    end
  end

  context 'Genre specific facets' do
    context 'Thesis/Dissertation' do
      it 'renders the Stanford student work facet when genre
          Thesis/Dissertation is selected' do
        visit search_catalog_path(f: { genre_ssim: ['Thesis/Dissertation'] })

        within('.facets') do
          expect(page).to have_css('h3', text: 'Stanford student work')
          expect(page).to have_css('a', text: 'Theses & dissertations')
        end
      end
      it 'renders the Stanford school or department facet when genre
          Thesis/Dissertation is selected' do
        visit search_catalog_path(f: { genre_ssim: ['Thesis/Dissertation'] })

        within('.facets') do
          expect(page).to have_css('h3', text: 'Stanford school or department')
        end
      end
    end
  end
end
