require "spec_helper"

describe "Responsive Home Page", feature: true, js: true do
  it "should show the facets on large screens" do
    visit root_path
    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      within("ul.facet-values") do
        expect(page).to have_css("li a", text: "Book", visible: true)
        expect(page).to have_css("li a", text: "Newspaper", visible: true)
      end
    end

    page.driver.resize("700", "700")

    within(".blacklight-format_main_ssim") do
      expect(page).to have_css(".panel-title", text: "Resource type")
      expect(page).not_to have_css("li a", text: "Book", visible: true)
      expect(page).not_to have_css("li a", text: "Newspaper", visible: true)
    end
  end
  it "should hide the feature descriptions on small screens" do
    visit root_path

    expect(page).to have_content("Images, maps, data, & more from the Stanford Digital Repository.", visible: true)
    expect(page).to have_content("Dissertations and theses in Stanford's collections.", visible: true)
    expect(page).to have_content("Not sure where to start? Find articles and reference information by discipline.", visible: true)

    page.driver.resize("700", "700")

    expect(page).not_to have_content("Images, maps, data, & more from the Stanford Digital Repository.", visible: true)
    expect(page).not_to have_content("Dissertations and theses in Stanford's collections.", visible: true)
    expect(page).not_to have_content("Not sure where to start? Find articles and reference information by discipline.", visible: true)
  end
end
