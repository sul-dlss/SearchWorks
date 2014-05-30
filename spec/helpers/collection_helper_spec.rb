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
      expect(collection_members_enumeration(document)).to eq "1 - 2 of 5 items online"
    end
    it "should not return anything if an document does not have collection members" do
      expect(collection_members_enumeration(no_collection_doc)).to be_nil
    end
  end
end
