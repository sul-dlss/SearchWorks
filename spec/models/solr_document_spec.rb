require "spec_helper"

describe SolrDocument do
  include MarcMetadataFixtures
  describe "marc field" do
    let(:marcxml) { SolrDocument.new(marcxml: metadata1) }
    let(:marcjson) { SolrDocument.new(marcjson_ss: marcxml.to_marc.to_hash.to_json) }

    it "should respond to #to_marc for marcxml" do
      expect(marcxml).to respond_to(:to_marc)
      expect(marcxml.to_marc).to be_a MARC::Record
    end

    it "should respond to #to_marc for marcjson" do
      expect(marcjson).to respond_to(:to_marc)
      expect(marcjson.to_marc).to be_a MARC::Record
    end
  end

  describe "MarcLinks" do
    it "should include marc links" do
      expect(subject).to be_kind_of MarcLinks
    end
  end

  describe "DatabaseDocument" do
    it "should include database document" do
      expect(subject).to be_kind_of DatabaseDocument
    end
  end

  describe "DisplayType" do
    it "should include display type" do
      expect(subject).to be_kind_of DisplayType
      expect(subject).to respond_to(:display_type)
    end
  end

  describe "DigitalCollection" do
    it "should include digital collection" do
      expect(subject).to be_kind_of DigitalCollection
    end
  end

  describe "CollectionMember" do
    it "should include collection member" do
      expect(subject).to be_kind_of CollectionMember
    end
  end

  describe "Extent" do
    it "should include the extent" do
      expect(subject).to be_kind_of Extent
    end
  end

  describe "IndexAuthors" do
    it "should include index authors" do
      expect(subject).to be_kind_of IndexAuthors
    end
  end

  describe "Druid" do
    it "should include druid" do
      expect(subject).to be_kind_of Druid
    end
  end

  describe 'StacksImages' do
    it 'includes the StacksImages mixin' do
      expect(subject).to be_kind_of StacksImages
    end
  end

  describe 'DigitalImage' do
    it 'includes the DigitalImage mixin' do
      expect(subject).to be_kind_of DigitalImage
    end
  end

  describe "SolrHoldings" do
    it "should include SolrHoldings" do
      expect(subject).to be_kind_of SolrHoldings
    end
  end

  describe 'SolrSet' do
    it 'should be included' do
      expect(subject).to be_kind_of SolrSet
    end
  end

  describe 'SolrBookplates' do
    it 'is included' do
      expect(subject).to be_kind_of SolrBookplates
    end
  end

  describe 'CitationConcern' do
    it 'is included' do
      expect(subject).to be_kind_of Citable
    end
  end

  describe 'MarcBoundWithNote' do
    it 'is included' do
      expect(subject).to be_kind_of MarcBoundWithNote
    end
  end

  describe 'MarcSeries' do
    it 'includes the linked_series method' do
      expect(subject).to respond_to :linked_series
    end

    it 'includes the unlinked_series method' do
      expect(subject).to respond_to :unlinked_series
    end
  end

  describe 'MarcOrganizationAndArrangement' do
    it 'adds the organization_and_arrangement method' do
      expect(subject).to respond_to :organization_and_arrangement
    end
  end

  describe '#id' do
    it 'escapes slashes' do
      expect(SolrDocument.new(id: 'abc/123').id).to eq 'abc%2F123'
    end
  end

  describe 'EdsDocument' do
    let(:eds) { SolrDocument.new(eds_title: 'yup') }
    let(:non_eds) { SolrDocument.new }

    it 'is included' do
      expect(subject).to be_kind_of EdsDocument
    end
    it 'eds?' do
      expect(eds.eds?).to eq true
      expect(non_eds.eds?).to eq false
    end
  end
end
