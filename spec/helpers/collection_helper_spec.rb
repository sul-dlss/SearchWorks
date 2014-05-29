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
end
