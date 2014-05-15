require 'spec_helper'

feature "Results Document Metadata" do

  scenario "should have correct tile with open-ended date range and metadata" do
    visit root_path
    first("#q").set '1'
    click_button 'search'

    within "#documents" do
      expect(page).to have_css("a", text: "An object", visible: true)
      expect(page).to have_css("span.main-title-date", text: "[2000 - ]", visible: false)

      within "ul.document-metadata" do
        expect(page).to have_css("li", text: "An object, aliquet sed mauris molestie, suscipit tempus", visible: true)
        expect(page).to have_css("li", text: "Doe, Jane", visible: true)
        expect(page).to have_css("li", text: "1990", visible: true)
      end
    end
  end

  scenario "should have 'sometime between' date range" do
    visit root_path
    first("#q").set '11'
    click_button 'search'

    within "#documents" do
      expect(page).to have_css("span.main-title-date", text: "[1801 ... 1837]", visible: false)
    end
  end


end
