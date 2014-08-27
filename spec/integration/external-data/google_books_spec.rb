require "spec_helper"

describe 'Google Books', type: :feature, js: :true, :"data-integration" => true do
  describe 'links in accordion section' do
    before do
      visit root_path
      fill_in 'q', with: 'lord bacon'
      click_button 'search'
    end

    it 'should include the Google book link in the snippet' do
      within(first('.document')) do
        within('.accordion-section.online') do
          expect(page).to have_css('.snippet a', text: 'Google Books (Full view)')
          find('a.header').click
          expect(page).not_to have_css('.snippet a', text: 'Google Books (Full view)')
          expect(page).to have_css('.details li a', text: 'Google Books (Full view)')
        end
      end
    end
  end
end
