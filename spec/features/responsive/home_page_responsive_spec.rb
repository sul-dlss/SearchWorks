require 'rails_helper'

RSpec.describe "Responsive Home Page", feature: true, js: true do
  describe "facets" do
    it "shows the facets on large screens" do
      visit root_path

      within(".blacklight-access_facet") do
        expect(page).to have_button 'Access'
        within("ul.facet-values") do
          expect(page).to have_css("li a", text: "Online", visible: true)
          expect(page).to have_css("li a", text: "At the Library", visible: true)
        end
      end
    end

    it 'collapses facets on small screens', page_width: 700, responsive: true do
      visit root_path

      within(".blacklight-access_facet") do
        expect(page).to have_button 'Access'
        expect(page).to have_no_css("li a", text: "Online", visible: true)
        expect(page).to have_no_css("li a", text: "At the Library", visible: true)
      end
    end
  end
end
