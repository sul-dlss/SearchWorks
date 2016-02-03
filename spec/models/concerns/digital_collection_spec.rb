require 'spec_helper'

describe DigitalCollection do
  let(:collection) { SolrDocument.new(collection_type: ["Digital Collection"], id: "1234") }
  let(:non_collection) { SolrDocument.new(collection_type: ["DigiColl"]) }
  describe "#is_a_collection?" do
    it "should be true when the collection_type is 'Digital Collection'" do
      expect(collection.is_a_collection?).to be_truthy
    end
    it "should be false when the collection_type is not 'Digital Collection'" do
      expect(non_collection.is_a_collection?).to be_falsey
    end
  end
  describe "CollectionMembers" do
    let(:collection_members) { DigitalCollection::CollectionMembers.new(collection) }
    let(:collection_members_with_rows) { DigitalCollection::CollectionMembers.new(collection, rows: 17) }
    let(:stub_solr) { double('solr') }
    let(:stub_params) { { params: {fq: "collection:\"1234\"", rows: 20}} }
    let(:rows_params) { { params: {fq: "collection:\"1234\"", rows: 17}} }
    let(:small_rows_params) { { params: {fq: "collection:\"1234\"", rows: 3}} }
    let(:stub_response) {{
      'response' => {
        'numFound' => 2,
        'docs' => [{id: 4321}, {id: 8765}]
      }
    }}
    before do
      allow(Blacklight).to receive(:solr).and_return(stub_solr)
    end
    it "should take a rows option" do
      expect(Blacklight.solr).to receive(:select).with(rows_params).and_return(stub_response)
      expect(collection_members_with_rows.documents).to be_present
    end
    it "should pass the rows option through collection_members" do
      expect(Blacklight.solr).to receive(:select).with(small_rows_params).and_return(stub_response)
      expect(collection.collection_members(rows: 3)).to be_present
    end
    describe "#documents" do
      it "solr documents should return collection members" do
        expect(collection.collection_members).to be_a(DigitalCollection::CollectionMembers)
      end
      it "should search solr for all members of a collection" do
        expect(Blacklight.solr).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.documents).to be_present
      end
      it "should return solr documents" do
        expect(Blacklight.solr).to receive(:select).with(stub_params).and_return(stub_response)
        collection_members.documents.each do |member|
          expect(member).to be_a SolrDocument
        end
      end
    end
    describe "#total" do
      it "should return the numFound integer" do
        expect(Blacklight.solr).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.total).to eq 2
      end
    end
    it "should return nil for a non-collection" do
      expect(non_collection.collection_members).to be_nil
    end
  end
end
