require "spec_helper"

describe "catalog/_index_image_collection.html.erb" do
  include ModsFixtures
  before do
    view.stub(:document).and_return(
      SolrDocument.new(
        modsxml: mods_everything,
        physical: ["The Physical Extent"]
      )
    )
    render
  end
  it "should include a link to the contributor" do
    expect(rendered).to have_css('li', text: 'J. Smith')
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Physical extent")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
end
