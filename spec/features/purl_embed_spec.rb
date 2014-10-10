require "spec_helper"

describe "PURL Embed", js: true do
  pending 'should be present for images' do
    visit catalog_path('mf774fs2413')
    within(".purl-embed-viewer") do
      expect(page).to have_css('#sul-embed-object')
      expect(page).to have_content("180 images")
      expect(page).to have_css(".sul-embed-purl-link", text: "purl.stanford.edu/mf774fs2413")
    end
  end
end
