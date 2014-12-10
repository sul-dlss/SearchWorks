require "spec_helper"

feature "Facets Customizations" do
  scenario "material type icons should display on the home page" do
    visit root_path

    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      within("ul.facet-values") do
        expect(page).to have_css("li span.sul-icon")
      end
    end
  end
  scenario "material type icons should display after an advanced search", js: true do
    visit advanced_search_path

    click_on "Resource type"
    check "f_inclusive_format_main_ssim_book"

    click_on "advanced-search-submit"

    expect(page).to have_css(".blacklight-format_main_ssim")

    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      expect(page).to have_css("li span.sul-icon")
    end
  end
  scenario 'resource type should be index sorted (not count)' do
    visit root_path

    book_index  = facet_index(facet_name: 'facet-format_main_ssim', value: 'Book')
    db_index    = facet_index(facet_name: 'facet-format_main_ssim', value: 'Database')
    image_index = facet_index(facet_name: 'facet-format_main_ssim', value: 'Image')

    expect(book_index).to be < db_index
    expect(db_index).to be < image_index
  end
  scenario 'library facet should be index sorted (not count)' do
    visit root_path

    green_index = facet_index(facet_name: 'facet-building_facet', value: 'Green')
    music_index = facet_index(facet_name: 'facet-building_facet', value: 'Music')
    sdr_index   = facet_index(facet_name: 'facet-building_facet', value: 'Stanford Digital Repository')

    expect(green_index).to be < music_index
    expect(music_index).to be < sdr_index
  end
  scenario "while not in an access point facet title should not change", js: true do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within "div#facets" do
      expect(page).to have_css("div.top-panel-heading.panel-heading h2", text: "Limit your search")
    end
  end

  scenario "while at an access point facet title should reflect custom heading" do
    visit '/databases'

    within "div#facets" do
      expect(page).to have_css("div.top-panel-heading.panel-heading h2", text: "Within databases")
    end
  end
end
