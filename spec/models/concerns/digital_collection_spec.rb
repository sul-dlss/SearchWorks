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
    let(:stub_params) { { params: { fq: "collection:\"1234\"", rows: 20 } } }
    let(:rows_params) { { params: { fq: "collection:\"1234\"", rows: 17 } } }
    let(:small_rows_params) { { params: { fq: "collection:\"1234\"", rows: 3 } } }
    let(:stub_response) { {
      'response' => {
        'numFound' => 2,
        'docs' => [{ id: 4321 }, { id: 8765 }]
      }
    }}

    before do
      allow(Blacklight.default_index).to receive(:connection).and_return(stub_solr)
    end

    describe "#documents" do
      it "solr documents should return collection members" do
        expect(collection.collection_members).to be_a(DigitalCollection::CollectionMembers)
      end
      it "should search solr for all members of a collection" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.documents).to be_present
      end
      it "should return solr documents" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        collection_members.documents.each do |member|
          expect(member).to be_a SolrDocument
        end
      end
    end

    describe "#total" do
      it "should return the numFound integer" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.total).to eq 2
      end
    end

    it "should return nil for a non-collection" do
      expect(non_collection.collection_members).to be_nil
    end
  end

  describe '#render_type' do
    before do
      allow(collection.collection_members).to receive_messages(documents:)
    end

    context 'when the majority of items have an image' do
      let(:documents) do
        [
          double('Document', image_urls: ['http:example.com/1']),
          double('Document', image_urls: ['http:example.com/2']),
          double('Document', image_urls: nil)
        ]
      end

      it 'is filmstrip' do
        expect(collection.collection_members.render_type).to eq 'filmstrip'
      end
    end

    context 'when the number of items that have images is equal to the number without' do
      let(:documents) do
        [
          double('Document', image_urls: ['http:example.com/1']),
          double('Document', image_urls: ['http:example.com/2']),
          double('Document', image_urls: nil),
          double('Document', image_urls: nil)
        ]
      end

      it 'is filmstrip' do
        expect(collection.collection_members.render_type).to eq 'filmstrip'
      end
    end

    context 'when the majority of items do not have an image' do
      let(:documents) do
        [
          double('Document', image_urls: ['http:example.com/1']),
          double('Document', image_urls: nil),
          double('Document', image_urls: nil)
        ]
      end

      it 'is list' do
        expect(collection.collection_members.render_type).to eq 'list'
      end
    end
  end
end
