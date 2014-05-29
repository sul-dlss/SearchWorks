require "spec_helper"

describe "catalog/_show_file.html.erb" do
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

  pending "should display table file list" do #wait until we have file items in the record
    # render
    # expect(rendered).to have_css("table.file-list-table thead th", text: "File (size)")
    # expect(rendered).to have_css("tr td", text: "jurrasic_park.jpg")
  end

end
