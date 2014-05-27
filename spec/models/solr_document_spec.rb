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
end
