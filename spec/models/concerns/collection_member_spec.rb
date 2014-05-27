require 'spec_helper'

describe CollectionMember do
  let(:member) { SolrDocument.new(collection: ["12345"]) }
  let(:non_member) { SolrDocument.new }
  let(:sirsi) { SolrDocument.new(collection: ['sirsi']) }
  let(:merged_sirsi) { SolrDocument.new(collection: ['sirsi', '12345']) }
  describe "#is_a_collection_member?" do
    it "should return true for collection members" do
      expect(member.is_a_collection_member?).to be_true
    end
    it "should return false for non collection members" do
      expect(non_member.is_a_collection_member?).to be_false
    end
    it "should return false for sirsi records" do
      expect(sirsi.is_a_collection_member?).to be_false
    end
    it "should return true for sirsi records that identify as being in another collection" do
      expect(merged_sirsi.is_a_collection_member?).to be_true
    end
  end
end