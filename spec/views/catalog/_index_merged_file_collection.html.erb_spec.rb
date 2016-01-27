require "spec_helper"

describe "catalog/_index_merged_file_collection.html.erb" do
  include MarcMetadataFixtures
  before do
    allow(view).to receive(:document).and_return(
      SolrDocument.new(
        marcbib_xml: metadata1,
        physical: ["The Physical Extent"],
        url_suppl: ["http://oac.cdlib.org/findaid/something-else"]
      )
    )
    render
  end
  it "should link to the author" do
    expect(rendered).to have_css('li a', text: 'Arbitrary, Stewart.')
  end
  it "should render the imprint" do
    expect(rendered).to have_css('li', text: 'Imprint Statement')
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Physical extent")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
  it "should include the finding aid when present" do
    expect(rendered).to have_css("dt", text: "Finding aid")
    expect(rendered).to have_css("dd a", text: "Online Archive of California")
  end
end
