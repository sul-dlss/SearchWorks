require "spec_helper"

describe "catalog/_show_file.html.erb" do
  include ModsFixtures
  let(:presenter) { OpenStruct.new(document_heading: "Object Title") }
  let(:document) { SolrDocument.new(druid: 'gz624pt5394', modsxml: mods_file) }
  before do
    allow(view).to receive(:presenter).and_return(presenter)
    assign(:document, document)
  end
  it "should display uppermetadata section" do
    render
    expect(rendered).to have_css("dl dt", text: "Author/Creator")
    expect(rendered).to have_css("dl dd", text: "J. Smith")
  end

  skip "should display table file list" do #wait until we have file items in the record
    # render
    # expect(rendered).to have_css("table.file-list-table thead th", text: "File (size)")
    # expect(rendered).to have_css("tr td", text: "jurrasic_park.jpg")
  end

end
