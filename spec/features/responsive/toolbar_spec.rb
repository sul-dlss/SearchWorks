require "spec_helper"

# TODO revisit on individual viewports, visible: true/false functionality not working correctly
describe "Responsive toolbar", js: true, feature: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  describe " - tablet view (768px - 980px) - " do
    it "should display correct tools" do
      # visit root_path
      # fill_in "q", with: ''
      # click_button 'search'
      # page.driver.resize(780, 700)
      # expect(page).to have_content '◄ 1 - 10 of 28 ►', visible: true
      # expect(page.find('div#sort-dropdown')).to have_content 'Sort', visible: true
      # expect(page.find('div#per_page-dropdown')).to have_content '10'
      # expect(page).to have_content '✔ all', visible: true
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct tools" do
      # visit root_path
      # fill_in "q", with: ''
      # click_button 'search'
      # page.driver.resize(500, 700)
      # expect(page).to have_no_content '◄ 1 - 10 of 28 ►'
      # expect(page.find('div#sort-dropdown')).to have_content 'Sort'
      # expect(page.find('div#per_page-dropdown')).to have_content '10'
      # expect(page).to have_content '✔ all', visible: true
    end
  end
end
