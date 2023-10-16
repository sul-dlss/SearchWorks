require 'rails_helper'

RSpec.feature "In collection Access Panel" do
  scenario "for MODS derived documents" do
    visit solr_document_path('mf774fs2413')

    within('.metadata-panels') do
      expect(page).to have_css('h2', text: 'Context')
    end

    within(".panel-in-collection") do
      within(".card-header") do
        expect(page).to have_content('Item belongs to a collection')
      end
      within('.card-body') do
        expect(page).to have_css("h4 a", text: "Image Collection1")
        expect(page).to have_css("[data-behavior='truncate']", text: /A collection of fixture images/)
        expect(page).to have_css("dt", text: 'Digital collection')
        expect(page).to have_css("dd a", text: /\d+ digital items?/)
        expect(page).to have_css("dt", text: "Finding aid")
        expect(page).to have_css("dd a", text: "Online Archive of California")
      end
    end
  end
end
