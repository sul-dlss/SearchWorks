require "spec_helper"

feature "Facets Customizations" do
  scenario "material type icons should display" do
    visit root_path

    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      within("ul.facet-values") do
        expect(page).to have_css("li span.sul-icon")
      end
    end
  end
  scenario "while not in an access point facet title should not change", js: true do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within "div#facets" do
      expect(page).to have_css("div.top-panel-heading.panel-heading h4", text: "Limit your search")
    end
  end

  scenario "while at an access point facet title should reflect custom heading" do
    visit '/databases'

    within "div#facets" do
      expect(page).to have_css("div.top-panel-heading.panel-heading h4", text: "Within databases")
    end
  end
end
