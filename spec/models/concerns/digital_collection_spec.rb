# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalCollection do
  let(:collection) { SolrDocument.new(collection_type: type, id: "1234") }
  let(:type) { ['Digital Collection'] }

  describe "#is_a_collection?" do
    subject { collection.is_a_collection? }

    context 'when the collection_type is "Digital Collection"' do
      it { is_expected.to be true }
    end

    context 'when the collection_type is not "Digital Collection"' do
      let(:type) { ['DigiColl'] }

      it { is_expected.to be false }
    end
  end

  describe '#collection_members' do
    subject { collection.collection_members }

    it { is_expected.to be_a(DigitalCollection::CollectionMembers) }

    context 'when the collection_type is not "Digital Collection"' do
      let(:type) { ['DigiColl'] }

      it { is_expected.to be_nil }
    end
  end

  describe "CollectionMembers" do
    let(:collection_members) { DigitalCollection::CollectionMembers.new(collection) }
    let(:collection_members_with_rows) { DigitalCollection::CollectionMembers.new(collection, rows: 17) }
    let(:stub_solr) { double('solr') }
    let(:stub_params) { { params: { fq: "collection:\"1234\" OR collection:\"a1234\"", rows: 20 } } }
    let(:rows_params) { { params: { fq: "collection:\"1234\" OR collection:\"a1234\"", rows: 17 } } }
    let(:small_rows_params) { { params: { fq: "collection:\"1234\" OR collection:\"a1234\"", rows: 3 } } }
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
      it "searches solr for all members of a collection" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.documents).to be_present
      end

      it "returns solr documents" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        collection_members.documents.each do |member|
          expect(member).to be_a SolrDocument
        end
      end
    end

    describe "#total" do
      it "returns the numFound integer" do
        expect(Blacklight.default_index.connection).to receive(:select).with(stub_params).and_return(stub_response)
        expect(collection_members.total).to eq 2
      end
    end
  end

  describe '#collection_id' do
    subject(:collection_id) { collection.collection_id }

    before do
      allow(collection.collection_members).to receive_messages(documents:)
    end

    context 'when the collection members store the collection id with an "a" prefix' do
      let(:documents) do
        [SolrDocument.new(id: 'abc', collection: ['a1234'])]
      end

      it 'returns the form of the collection id stored on the collection members' do
        expect(collection_id).to eq 'a1234'
      end
    end

    context 'when the collection members store the collection id without an "a" prefix' do
      let(:documents) do
        [SolrDocument.new(id: 'abc', collection: ['1234'])]
      end

      it 'returns the form of the collection id stored on the collection members' do
        expect(collection_id).to eq '1234'
      end
    end

    context 'when the collection members store other collection ids' do
      let(:documents) do
        [SolrDocument.new(id: 'abc', collection: ['a5678', 'a1234'])]
      end

      it 'returns the id matching the current collection' do
        expect(collection_id).to eq 'a1234'
      end
    end

    context 'when collection_members has no documents' do
      let(:documents) { [] }

      it { is_expected.to be_nil }
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
