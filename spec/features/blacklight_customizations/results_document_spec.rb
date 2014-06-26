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

  scenario "should have correct cover image attributes", js: true do
    visit root_path
    first("#q").set '10'
    click_button 'search'

    within "#documents" do
      within "div.document" do
        expect(page).to have_css("img.cover-image", visible: true)
        expect(page).to have_css("img.cover-image.ISBN0393040801.ISBN9780393040807.OCLC36024029.LCCN96049953", visible: true)
        expect(page).to have_css("img.cover-image[data-isbn='ISBN0393040801,ISBN9780393040807']", visible: true)
        expect(page).to have_css("img.cover-image[data-lccn='LCCN96049953']", visible: true)
        expect(page).to have_css("img.cover-image[data-oclc='OCLC36024029']", visible: true)
        expect(page).to have_css("img.cover-image[src='http://bks0.books.google.com/books?id=3xmDzzNiwiUC&printsec=frontcover&img=1&zoom=1']", visible: true)
      end
    end
  end

  scenario "should have the stacks image for objects with image behavior" do
    visit root_path
    first("#q").set '35'
    click_button 'search'

    within 'div.document' do
      expect(page).to have_css('img.stacks-image')
    end
  end

end
