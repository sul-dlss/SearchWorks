require "spec_helper"

describe CollectionHelper do
  describe "#link_to_collection_members" do
    let(:document) { SolrDocument.new(id: '1234') }
    it "should link to the given text" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href.*>LinkText<\/a>/
    end
    it "should link document id" do
      expect(link_to_collection_members("LinkText", document)).to match /<a href=\".*collection.*=1234\".*/
    end
  end
  describe "#collections_search_params" do
    it "should be the collection_type facet value of 'Digital Collection" do
      expect(collections_search_params).to have_key(:f)
      expect(collections_search_params[:f]).to have_key(:collection_type)
      expect(collections_search_params[:f][:collection_type]).to eq ["Digital Collection"]
    end
  end
  describe "#collection_members_enumeration" do
    let(:document) { SolrDocument.new }
    let(:collection_members) { [SolrDocument.new, SolrDocument.new] }
    let(:no_collection_doc) { SolrDocument.new }
    before do
      collection_members.stub(:total).and_return("5")
      document.stub(:collection_members).and_return(collection_members)
      no_collection_doc.stub(:collection_members).and_return([])
    end
    it "should return the correct number of document including the #total" do
      expect(collection_members_enumeration(document)).to eq "5 items online"
    end
    it "should not return anything if an document does not have collection members" do
      expect(collection_members_enumeration(no_collection_doc)).to be_nil
    end
  end
  describe "#collection_breadcrumb_value" do
    it "should return the collection name when present in the @document_list" do
      helper.stub(:presenter).and_return(
        OpenStruct.new(document_heading: 'Title2')
      )
      @document_list = [
        SolrDocument.new(collection: ['12345', '54321'], collection_with_title: ['12345 -|- Title1', '54321 -|- Title2'])
      ]
      expect(helper.send(:collection_breadcrumb_value, '54321')).to eq 'Title2'
    end
    it "should return the ID if there is no @documen_list" do
      expect(helper.send(:collection_breadcrumb_value, '54321')).to eq '54321'
    end
    it "should return the ID if there are no matching collections in the @document_list" do
      @document_list = [
        SolrDocument.new(collection: ['12345', '54321'], collection_with_title: ['12345 -|- Title1', '54321 -|- Title2'])
      ]
      expect(helper.send(:collection_breadcrumb_value, '11111')).to eq '11111'
    end
  end
end
