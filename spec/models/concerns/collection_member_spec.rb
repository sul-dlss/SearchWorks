require 'spec_helper'

describe CollectionMember do
  let(:member) { SolrDocument.new(collection: ["12345"]) }
  let(:non_member) { SolrDocument.new }
  let(:sirsi) { SolrDocument.new(collection: ['sirsi']) }
  let(:merged_sirsi) { SolrDocument.new(collection: ['sirsi', '12345']) }
  describe "#is_a_collection_member?" do
    it "should return true for collection members" do
      expect(member.is_a_collection_member?).to be_truthy
    end
    it "should return false for non collection members" do
      expect(non_member.is_a_collection_member?).to be_falsey
    end
    it "should return false for sirsi records" do
      expect(sirsi.is_a_collection_member?).to be_falsey
    end
    it "should return true for sirsi records that identify as being in another collection" do
      expect(merged_sirsi.is_a_collection_member?).to be_truthy
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
      allow(Blacklight).to receive(:solr).and_return(stub_solr)
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
  describe "index_parent_collections" do
    let(:document_with_parent) {
      SolrDocument.new(
        collection: ['12345', '54321'],
        collection_with_title: [
          '12345 -|- Collection1 Title',
          '54321 -|- Collection2 Title'
        ]
      )
    }
    let(:document_without_parent) { SolrDocument.new() }
    it "should return the parent collections from the index" do
      collections = document_with_parent.index_parent_collections
      expect(collections.length).to eq 2
      expect(collections.first).to be_a SolrDocument
      expect(collections.first[:id]).to eq '12345'
      expect(collections.first[:title_display]).to eq 'Collection1 Title'

      expect(collections.last).to be_a SolrDocument
      expect(collections.last[:id]).to eq '54321'
      expect(collections.last[:title_display]).to eq 'Collection2 Title'
    end
    it "should return nil if the document is not a collection member" do
      expect(document_without_parent.index_parent_collections).to be_nil
    end
  end
end