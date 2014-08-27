require 'spec_helper'

feature "Record view" do

  scenario "should have online books panel with Google links", js: true do
    visit catalog_path('44')

    within "div.document" do
      expect(page).to have_css("div.panel-online", visible: true)

      within "div.panel-online" do
        expect(page).to have_css("div.panel-heading", visible: true)
        expect(page).to have_css("h3", text: "Available online", visible: true)
        expect(page).to have_css("a.full-view[href='http://books.google.com/books?id=GqKSckP3uRIC&printsec=frontcover&source=gbs_ViewAPI']", text: "(Full view)", visible: true)
        expect(page).to have_css("img[src='/assets/gbs_preview_button.gif']")
      end
    end
  end

  scenario "should have related panel with Google links", js: true do
    visit catalog_path('10')

    within "div.document" do
      expect(page).to have_css("div.panel-related", visible: true)

      within "div.panel-related" do
        expect(page).to have_css("div.panel-heading", visible: true)
        expect(page).to have_css("h3", text: "Related", visible: true)
        expect(page).to have_css("a.limited-preview[href='http://books.google.com/books?id=3xmDzzNiwiUC&printsec=frontcover&source=gbs_ViewAPI']", text: "(Limited preview)", visible: true)
        expect(page).to have_css("img[src='/assets/gbs_preview_button.gif']")
      end
    end

  end


end
