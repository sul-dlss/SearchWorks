# encoding: UTF-8

require "spec_helper"

feature "Pagination customization", "data-integration": true do
  before do
    skip("Needs format/resource-type facet to settle down")
    visit root_path
    within(first('.home-facet')) do
      click_link 'Book'
    end
  end

  scenario "should not have deep paging links" do
    within('ul.pagination') do
      expect(page).to have_css('li a', count: 8) # would be 10 w/ deep paging links
      expect(page).not_to have_css('li a', text: /\d{3},\d{3}/) # should not contain a link in the 100k range
      expect(page).not_to have_css('li a', text: /\d{1,3}.\d{3},\d{3}/) # should not contain a link in the million range
    end
  end
  scenario "should have an overridden character" do
    within('ul.pagination') do
      expect(page).to have_css('li span', text: /Previous/)
      expect(page).not_to have_css('li a', text: /Previous/)
      expect(page).to have_css('li a', text: /Next/)
    end
  end
  scenario "should have previous link enabled" do
    page.find('li a[rel="next"]').click
    expect(page).to have_css('li a', text: /Previous/)
    expect(page).not_to have_css('li span', text: /Previous/)
  end
end
