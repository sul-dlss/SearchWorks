require "spec_helper"

describe 'Digital Collections Access Point' do
  before do
    visit root_path
    click_link "Digital collections"
  end
  it 'should include the digital collections masthead' do
    within(".digital-collections-masthead") do
      expect(page).to have_css('h1', text: 'Digital collections')
      expect(page).to have_css('.inline-links a', text: 'data')
      expect(page).to have_css('.inline-links a', text: 'images')
      expect(page).to have_css('.inline-links a', text: 'maps')
      expect(page).to have_css('.inline-links a', text: 'all items')
    end
  end
end
