require "spec_helper"

feature "Facets Customizations" do
  scenario "material type icons should display" do
    visit root_path

    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      within("ul.facet-values") do
        expect(page).to have_css("li img.facet-icon")
      end
    end
  end
end
