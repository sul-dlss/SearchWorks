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
  describe "#parent_collections" do
    let(:multi_collection) { SolrDocument.new( collection: ['12345', '54321'] ) }
    let(:stub_solr) { double('solr') }
    let(:stub_params) { { params: {fq: "id:12345"}} }
    let(:stub_response) {{
      'response' => {
        'docs' => [{id: 12345}]
      }
    }}
    before do
      Blacklight.stub(:solr).and_return(stub_solr)
    end
    it "should search solr for ids in the collection" do
      expect(Blacklight.solr).to receive(:select).with(stub_params).and_return(stub_response)
      expect(member.parent_collections).to be_present
    end
    it "should return a solr document" do
      expect(Blacklight.solr).to receive(:select).with(stub_params).and_return(stub_response)
      member.parent_collections.each do |parent|
        expect(parent).to be_a SolrDocument
      end
    end
    it "#parent_collection_params should return all IDs joined w/ OR" do
      expect(multi_collection.send(:parent_collection_params)).to eq "id:12345 OR id:54321"
    end
    it "should return nil for non collection members" do
      expect(non_member.parent_collections).to be_nil
    end
  end
end