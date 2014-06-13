# encoding: UTF-8

require "spec_helper"

feature "Pagination customization", :"data-integration" => true do
  before do
    pending("Needs format/resource-type facet to settle down")
    visit root_path
    within(first('.home-facet')) do
      click_link 'Book'
    end
  end
  scenario "should not have deep paging links" do
    within('ul.pagination') do
      expect(page).to have_css('li a', count: 8) # would be 10 w/ deep paging links
      expect(page).to_not have_css('li a', text: /\d{3},\d{3}/) # should not contain a link in the 100k range
      expect(page).to_not have_css('li a', text: /\d{1,3}.\d{3},\d{3}/) # should not contain a link in the million range
    end
  end
  scenario "should have an overridden character" do
    within('ul.pagination') do
      expect(page).to have_css('li a', text: "◄ Previous")
      expect(page).to have_css('li a', text: "Next ►")
    end
  end
end
