require 'rails_helper'

RSpec.describe "Record view", :feature do
  it "should display records from the index" do
    visit solr_document_path("1")
    expect(page).to have_css("h1", text: "An object")
  end
  it 'should display the correct COinS' do
    visit solr_document_path("1")
    expect(page).to have_css('span.Z3988[title*="fmt%3Akev%3Amtx%3Abook"]')
  end
end
