require "spec_helper"

describe "catalog/_index_image.html.erb" do
  before do
    view.stub(:document).and_return(SolrDocument.new(physical: ["The Physical Extent"]))
    view.stub(:blacklight_config).and_return( Blacklight::Configuration.new )
    render
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Physical extent:")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
end
