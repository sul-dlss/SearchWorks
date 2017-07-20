require "spec_helper"

describe 'SDR Access Point' do
  before do
    visit root_path
    click_link "Stanford Digital Repository"
  end
  it 'should have a custom page title' do
    expect(page).to have_title("SDR items in SearchWorks catalog")
  end
  it 'should include the SDR masthead' do
    within(".sdr-masthead") do
      expect(page).to have_css('h1', text: 'Stanford Digital Repository')
      expect(page).to have_css('.inline-links a', text: 'data')
      expect(page).to have_css('.inline-links a', text: 'images')
      expect(page).to have_css('.inline-links a', text: 'maps')
      expect(page).to have_css('.inline-links a', text: 'collections')
    end
  end
end
