require 'spec_helper'

feature "Course Reserve Access Panel" do

  scenario "should have 3 course reservations" do
    visit '/view/1'
    within "div.panel-course-reserve" do
      expect(page).to have_css('div.course-reserve-course', count: 3, text: "COURSE:")
      expect(page).to have_css('span.course-reserve-title', text: "COURSE:")
      expect(page).to have_css('a', text: "ACCT-212-01-02 -- Managerial Accounting: Base")
      expect(page).to have_css('div.course-reserve-instructor', text: "INSTRUCTOR(S):")
    end
  end

  scenario "should have 1 course reservations" do
    visit '/view/2'
    within "div.panel-course-reserve" do
      expect(page).to have_css('div.course-reserve-course', count: 1, text: "CAT-401-01-01 -- Emergency Kittenz")
      expect(page).to have_css('span.course-reserve-title', text: "COURSE:")
      expect(page).to have_css('a', text: "CAT-401-01-01 -- Emergency Kittenz")
      expect(page).to have_css('div.course-reserve-instructor', text: "INSTRUCTOR(S): McDonald, Ronald")
    end
  end

  scenario "should have 0 course reservations" do
    visit '/view/3'
    expect(page.has_no_css?('div.panel-course-reserve')).to eql true

  end

end
