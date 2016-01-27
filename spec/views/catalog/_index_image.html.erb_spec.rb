require "spec_helper"

describe "catalog/_index_image.html.erb" do
  include ModsFixtures
  let(:presenter) { OpenStruct.new(document_heading: "Object Title") }
  before do
    allow(view).to receive(:document).and_return(
      SolrDocument.new(
        collection: ['12345'],
        collection_with_title: ['12345 -|- Collection Title'],
        modsxml: mods_everything,
        physical: ["The Physical Extent"],
        imprint_display: ["Imprint Statement"]
      )
    )
    expect(view).to receive(:presenter).and_return(presenter)
    allow(view).to receive(:blacklight_config).and_return( Blacklight::Configuration.new )
    render
  end
  it "should include the imprint" do
    expect(rendered).to have_css('li', text: "Imprint Statement")
  end
  it "should include the first contributor" do
    expect(rendered).to have_css('li a', text: 'J. Smith')
  end
  it "should include the physical extent" do
    expect(rendered).to have_css("dt", text: "Physical extent")
    expect(rendered).to have_css("dd", text: "The Physical Extent")
  end
  it "should include the collection" do
    expect(rendered).to have_css('dt', text: 'Collection')
  end
end
