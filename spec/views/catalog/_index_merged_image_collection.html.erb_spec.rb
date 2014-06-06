require "spec_helper"

describe "catalog/_index_merged_image_collection.html.erb" do
  before do
    view.stub(:document).and_return(
      SolrDocument.new(
        physical: ["The Physical Extent"],
        url_suppl: ["http://oac.cdlib.org/findaid/something-else"]
      )
    )
    view.stub(:blacklight_config).and_return( Blacklight::Configuration.new )
    render
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "PHYSICAL EXTENT:")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
  it "should include the finding aid when present" do
    expect(rendered).to have_css("dt", text: "FINDING AID:")
    expect(rendered).to have_css("dd a", text: "Online Archive of California")
  end
end
