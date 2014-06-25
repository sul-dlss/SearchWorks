require "spec_helper"

describe "catalog/_index_marc.html.erb" do
  before do
    view.stub(:document).and_return(SolrDocument.new(physical: ["The Physical Extent"], format_main_ssim: ['Book']))
    view.stub(:blacklight_config).and_return( Blacklight::Configuration.new )
    render
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "BOOK:")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
end
