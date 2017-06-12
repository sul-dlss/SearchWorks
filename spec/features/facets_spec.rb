require 'spec_helper'

describe 'Facets' do
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

    context 'other libraries' do
      it 'does not render the location facet' do
        visit root_path

        click_link 'Green'

        within('.facets') do
          expect(page).not_to have_css('h3', text: 'Location')
        end
      end
    end
  end
end
