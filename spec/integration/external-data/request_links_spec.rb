require "spec_helper"

describe 'Request Links', type: :feature, :"data-integration" => true do
  describe 'Location level request links' do
    it 'should be rendered for configured -30 locations' do
      visit catalog_path '4085340'

      within('ul.location') do
        expect(page).to have_css('li', text: /University Archives\s*Request/)
        expect(page).to have_css('li a', text: "Request")
      end
    end
  end
end