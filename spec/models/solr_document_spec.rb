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
end
