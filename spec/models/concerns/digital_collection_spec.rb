require 'spec_helper'

describe DigitalCollection do
  let(:collection)     { SolrDocument.new(collection_type: ["Digital Collection"]) }
  let(:non_collection) { SolrDocument.new(collection_type: ["DigiColl"]) }
  describe "#is_a_collection?" do
    it "should be true when the collection_type is 'Digital Collection'" do
      expect(collection.is_a_collection?).to be_true
    end
    it "should be false when the collection_type is not 'Digital Collection'" do
      expect(non_collection.is_a_collection?).to be_false
    end
  end
end
