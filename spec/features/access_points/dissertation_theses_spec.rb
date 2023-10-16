require 'rails_helper'

RSpec.describe 'Dissertation Theses Access Point' do
  before do
    visit root_path
    click_link 'Theses & dissertations'
  end

  it 'should have a custom page title' do
    expect(page).to have_title('Dissertation theses in SearchWorks catalog')
  end
  it 'should include the dissertation/theses masthead' do
    within(".dissertation-theses-masthead") do
      expect(page).to have_css('h1', text: 'Theses and dissertations')
    end
  end
end
