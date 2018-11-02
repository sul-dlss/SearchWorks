require "spec_helper"

describe "catalog/access_panels/_collection_details.html.erb" do
  describe "not a collection" do
    before do
      assign(:document, SolrDocument.new())
      render
    end
    it "should not render a panel" do
      expect(rendered).to be_blank
    end
  end
  describe "for a collection" do
    let(:document) {
      SolrDocument.new(
        id: '1234',
        druid: '1234',
        physical: ['2 things'],
        collection_type: ["Digital Collection"]
      )
    }
    let(:collection_members) { ['a', 'b'] }
    before do
      allow(collection_members).to receive(:total).and_return(2)
      allow(document).to receive(:collection_members).and_return(collection_members)
      assign(:document, document)
      render
    end
    it "should render an access panel" do
      expect(rendered).to have_css('.panel-collection-details')
      expect(rendered).to have_css('.panel-heading', text: 'Collection details')
      expect(rendered).to have_css('dt', text: 'Digital content', visible: false)
      expect(rendered).to have_css('dd a', text: 'item', visible: false)
      expect(rendered).to have_css('dt', text: 'Description')
      expect(rendered).to have_css('dd', text: '2 things')
      expect(rendered).to have_css('dt', text: 'Collection PURL')
      expect(rendered).to have_css('dd a', text: 'https://purl.stanford.edu/1234')
    end
  end
end
