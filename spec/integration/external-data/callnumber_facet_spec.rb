require "spec_helper"

describe "Callnumber facet", feature: true, js: true, :"data-integration" => true do
  before do
    visit root_path
    click_link "At the Library"
  end

  it 'should collapse the call numbers' do
    within("#facets") do
      within(".facet_limit.blacklight-callnum_facet_hsim") do
        click_link("Call number")
        expect(page).to have_css('li.h-node', count: 3)
        expect(page).to have_css('li.h-node a', text: 'Dewey Classification')
        expect(page).to have_css('li.h-node a', text: 'Government Document')
        expect(page).to have_css('li.h-node a', text: 'LC Classification')
        click_link('LC Classification')
      end
    end
  end
end
