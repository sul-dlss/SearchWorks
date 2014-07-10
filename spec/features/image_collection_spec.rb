require "spec_helper"

feature "Image Collection" do
  scenario "Search results" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css("h3 a", text: "Image Collection1") #title
    expect(page).to have_css("[data-behavior='trunk8']", text: /Nunc venenatis et odio ac elementum/) # truncated summary
    expect(page).to have_css("dt", text: "Digital content")
    expect(page).to have_css("dd", text: /\d+ items?/) # collection members
  end

  scenario "Record view" do
    visit catalog_path('29')

    expect(page).to have_css("h1", text: "Image Collection1") # Title
    expect(page).to have_css("h2", text: "Subjects")
    expect(page).to have_css("h2", text: "Bibliographic information")
    expect(page).to have_css("h2", text: "Access conditions")

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css("button.prev")
      expect(page).to have_css("button.next")
      expect(page).to have_css(".viewport .container-images")

      within ".viewport .container-images" do
        expect(page).to have_css("a[href='/view/mf774fs2413']")
      end
    end

  end

  scenario "Search results image filmstrip" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css("button.prev")
      expect(page).to have_css("button.next")
      expect(page).to have_css(".viewport .container-images")

      within ".viewport .container-images" do
        expect(page).to have_css("li[data-behavior='preview-filmstrip']")
        expect(page).to have_css("a[href='/view/mf774fs2413']")
      end
    end
  end

  scenario "Search results image filmstrip preview" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css("div.preview-container-29")
    end

  end

end
