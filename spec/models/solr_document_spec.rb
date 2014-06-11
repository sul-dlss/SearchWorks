require "spec_helper"

describe SolrDocument do
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
