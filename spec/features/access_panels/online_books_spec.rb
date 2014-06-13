require 'spec_helper'

feature "Record view" do
  before do
    visit('/catalog/10')
  end

  scenario "should have online books panel with Google links", js: true do

    within "div.document" do
      expect(page).to have_css("div.panel-online", visible: true)

      within "div.panel-online" do
        expect(page).to have_css("div.panel-heading", visible: true)
        expect(page).to have_css("a.about[href='http://books.google.com/books?id=3xmDzzNiwiUC&source=gbs_ViewAPI']", text: "About this book", visible: true)
        expect(page).to have_css("a.limited-preview[href='http://books.google.com/books?id=3xmDzzNiwiUC&printsec=frontcover&source=gbs_ViewAPI']", text: "Limited preview", visible: true)
        expect(page).to have_css("a.preview-link[href='http://books.google.com/books?id=3xmDzzNiwiUC&printsec=frontcover&source=gbs_ViewAPI']")
      end
    end

  end

end
