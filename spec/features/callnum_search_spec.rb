require 'spec_helper'

describe 'Call num search' do
  it "should correctly show a search result when the call number has special characters in it" do
    object_title='An object'
    visit root_url
    fill_in "q", with: "g70.212 .a426 2011:test"
    select 'Call number', from: 'search_field'
    click_button 'search'
    within "#content" do
      expect(page).to have_css('h3.index_title', text: object_title)
    end
    click_link object_title
    within "#doc_1" do
      expect(page).to have_css('h1', text: object_title)
    end
  end
end
