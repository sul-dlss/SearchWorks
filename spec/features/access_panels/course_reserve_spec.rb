require 'rails_helper'

RSpec.feature "Course Reserve Access Panel" do
  scenario "should have 3 course reservations" do
    visit '/view/1'
    within "div.panel-course-reserve" do
      expect(page).to have_css('dl')
      expect(page).to have_css('dt', count: 3, text: "Course")
      expect(page).to have_css('dt', text: "Course")
      expect(page).to have_css('dd a', text: "ACCT-212-01-02 -- Managerial Accounting: Base")
      expect(page).to have_css('dt', text: "Instructor(s)")
    end
  end

  scenario "should have 1 course reservations" do
    visit '/view/2'
    within "div.panel-course-reserve" do
      expect(page).to have_css('dd', count: 1, text: "CAT-401-01-01 -- Emergency Kittenz")
      expect(page).to have_css('dt', text: "Course")
      expect(page).to have_css('dd a', text: "CAT-401-01-01 -- Emergency Kittenz")
      expect(page).to have_css('dt', text: "Instructor(s)")
      expect(page).to have_css('dd', text: "McDonald, Ronald")
    end
  end

  scenario "should have 0 course reservations" do
    visit '/view/3'
    expect(page.has_no_css?('div.panel-course-reserve')).to be true
  end
end
