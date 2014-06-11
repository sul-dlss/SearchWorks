require "spec_helper"

describe "preview/_show_file.html.erb" do
  include ModsFixtures

  let(:document) { SolrDocument.new(modsxml: mods_file) }
  before do
    assign(:document, document)
  end
  it "should display uppermetadata section" do
    render
    expect(rendered).to have_css("dl dt", text: "Author/Creator")
    expect(rendered).to have_css("dl dd", text: "J. Smith")
  end
end
