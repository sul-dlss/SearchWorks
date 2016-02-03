require 'spec_helper'

feature 'Bookmarking Items' do
  context 'Citations', js: true do
    let(:citations) { '<p class="citation_style_MLA">MLA Citation</p>' }
    before { stub_oclc_response(citations, for: '12345') }

    scenario 'should be viewable grouped by title and citation format' do
      visit root_path
      fill_in :q, with: ''
      click_button 'search'

      within(all('.document').first) do
        find('input.toggle_bookmark').click
      end

      wait_for_ajax

      within(all('.document').last) do
        find('input.toggle_bookmark').click
      end

      wait_for_ajax

      visit '/selections'

      expect(page).to have_css('.document', count: 2)

      click_link 'Cite 1 - 2'

      wait_for_ajax

      within('.modal-dialog') do
        expect(page).to have_css('h4', text: 'MLA', count: 2)
        click_link 'By citation format'
        expect(page).to have_css('h4', text: 'MLA', count: 1)
        expect(page).to have_css('p.citation_style_MLA', count: 2)
      end
    end
  end
end
