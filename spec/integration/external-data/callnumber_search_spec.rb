require "spec_helper"

describe "Callnumber Search", feature: true, "data-integration": true do
  before do
    visit root_path
    fill_in 'q', with: 'JQ1879 .A15 D385'
    select 'Call number', from: 'search_field'
    click_button 'search'
  end

  it "should quote and downcase the callnumber" do
    expect(find('#q').value).to eq '"jq1879 .a15 d385"'
    within('.breadcrumb') do
      expect(page).to have_css('.filterName', text: 'Call number')
      expect(page).to have_css('.filterValue', text: '"jq1879 .a15 d385"')
    end
  end
  it "should return the relevant result" do
    expect(page).to have_css('.document', count: 1)
    expect(page).to have_css('.index_title', text: /African world histories/)
  end
end
