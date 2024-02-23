require 'rails_helper'

RSpec.feature "Course Reserve Access Panel" do
  scenario "should have 3 course reservations" do
    visit '/view/1'
    within "div.panel-course-reserve" do
      expect(page).to have_css('dl')
      expect(page).to have_css('dt', count: 3, text: "Course")
      expect(page).to have_css('dt', text: "Course")
      expect(page).to have_css('dd a')
      expect(page).to have_css('dt', text: "Instructor(s)")
    end
  end

  scenario "should have 1 course reservations" do
    visit '/view/2'
    within "div.panel-course-reserve" do
      expect(page).to have_css('dt', text: "Course")
      expect(page).to have_css('dd a', count: 1)
      expect(page).to have_css('dt', text: "Instructor(s)")
    end
  end

  scenario "should have 0 course reservations" do
    visit '/view/3'
    expect(page.has_no_css?('div.panel-course-reserve')).to be true
  end
end
