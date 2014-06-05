require "spec_helper"

describe "catalog/_index_image_collection.html.erb" do
  before do
    view.stub(:document).and_return(SolrDocument.new(physical: ["The Physical Extent"]))
    render
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "PHYSICAL EXTENT:")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
end
