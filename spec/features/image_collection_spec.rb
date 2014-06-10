require "spec_helper"

feature "Image Collection" do
  scenario "Search results" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css("h5 a", text: "Image Collection1") #title
    expect(page).to have_css("[data-behavior='truncate']", text: /A collection of fixture images/) # truncated summary
    expect(page).to have_css("dt", text: "DIGITAL CONTENT")
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
        expect(page).to have_css("a[href='/catalog/mf774fs2413']")
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
        expect(page).to have_css("li.preview-source-mf774fs2413")
        expect(page).to have_css("a[href='/catalog/mf774fs2413']")
      end
    end
  end

  scenario "Search results image filmstrip preview" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css("ul.container-previews")

      within "ul.container-previews" do
        expect(page).to have_css("li.preview-target-mf774fs2413")

        within "li.preview-target-mf774fs2413" do
          expect(page).to have_css(".preview-arrow")
          expect(page).to have_css("a.preview-close")
          expect(page).to have_css("a[href='/catalog/mf774fs2413']")
        end
      end
    end
  end

end
