require "spec_helper"

describe "catalog/_index_merged_image.html.erb" do
  include MarcMetadataFixtures
  let(:presenter) { OpenStruct.new(document_heading: "Object Title") }
  before do
    allow(view).to receive(:document).and_return(
      SolrDocument.new(
        collection: ['12345'],
        collection_with_title: ['12345 -|- Collection Title'],
        marcbib_xml: metadata1,
        physical: ["The Physical Extent"],
        url_fulltext: ['http://oac.cdlib.org/findaid/12345']
      )
    )
    expect(view).to receive(:presenter).and_return(presenter)
    allow(view).to receive(:blacklight_config).and_return( Blacklight::Configuration.new )
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
  it "should include the collection" do
    expect(rendered).to have_css('dt', text: 'Collection')
  end
  it 'should include the finding aid' do
    expect(rendered).to have_css('dt', text: 'Finding aid')
    expect(rendered).to have_css('dd a', text: 'Online Archive of California')
  end
end
