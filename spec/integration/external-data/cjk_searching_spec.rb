# encoding: utf-8

require "spec_helper"

describe "CJK Searching", feature: true, :"data-integration" => true do
  it "should return results for an everything search" do
    visit root_path
    fill_in 'q', with: '郑州地理'
    click_button 'search'

    expect(page).to have_css('.document')
    expect(page).to have_css('h2', text: /\d+ results/)
  end

  it "should return results for an author search" do
    visit root_path
    fill_in 'q', with: '釘貫'
    select 'Author', from: 'search_field'
    click_button 'search'

    expect(page).to have_css('.document')
    expect(page).to have_css('h2', text: /\d+ results?/)
  end

  it "should return results for a title search" do
    visit root_path
    fill_in 'q', with: '中国  地方志  集成'
    select 'Title', from: 'search_field'
    click_button 'search'

    expect(page).to have_css('.document')
    expect(page).to have_css('h2', text: /\d+ results/)
  end
end
