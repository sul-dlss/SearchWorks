require "spec_helper"

describe "Record view", feature: true, "data-integration": true do
  it "should display records from the index" do
    visit solr_document_path("2818067")
    expect(page).to have_css("h1", text: "10 kW power electronics for hydrogen arcjets [microform]")
  end
  it 'should display the correct COinS' do
    visit solr_document_path("6749121")
    expect(page).to have_css('span.Z3988[title*="fmt%3Akev%3Amtx%3Abook"]')
  end
end