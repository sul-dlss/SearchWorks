require "spec_helper"

describe SolrDocument do
  include MarcMetadataFixtures
  describe "marc field" do
    let(:marcxml) { SolrDocument.new( marcxml: metadata1 ) }
    let(:marcbib_xml) { SolrDocument.new( marcbib_xml: metadata1 ) }
    it "should respond to #to_marc for for marcxml" do
      expect(marcxml).to respond_to(:to_marc)
      expect(marcxml.to_marc).to be_a MARC::Record
      expect(marcxml.to_marc).to eq marcbib_xml.to_marc
    end
    it "should respond to #to_marc for for marcbib_xml" do
      expect(marcbib_xml).to respond_to(:to_marc)
      expect(marcbib_xml.to_marc).to be_a MARC::Record
      expect(marcbib_xml.to_marc).to eq marcxml.to_marc
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
  describe "MarcCharacteristics" do
    it "should include the marc characteristics" do
      expect(subject).to be_kind_of MarcCharacteristics
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
  describe "OpenSeadragon" do
    it "should include OpenSeadragon" do
      expect(subject).to be_kind_of OpenSeadragon
    end
  end
  describe "SolrHoldings" do
    it "should include SolrHoldings" do
      expect(subject).to be_kind_of SolrHoldings
    end
  end
end
