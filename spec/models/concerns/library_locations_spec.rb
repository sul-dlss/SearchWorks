require 'spec_helper'

class LibraryLocationsTestClass
  include LibraryLocations
end

describe LibraryLocations do
  it "should return nil for non library location docs" do
    expect(LibraryLocationsTestClass.new.library_locations).to be_nil
  end

  describe "present?" do
    it "should return false" do
      expect(LibraryLocationsTestClass.new.library_locations.present?).to be_false
    end

    it "should return true" do
      doc = SolrDocument.new(id: '123', item_display: ["123 -|- CHEMCHMENG","456 -|- CHEMCHMENG","123 -|- CHEMCHMENG","678 -|- EARTH-SCI","123 -|- CHEMCHMENG","543 -|- BIOLOGY"])
      expect(doc.library_locations.present?).to be_true
    end
  end

  describe "grouped_attributes" do
    it "should return the second delmited value" do
      doc = SolrDocument.new(id: '123', item_display: ["123 -|- CHEMCHMENG"])
      expect(doc.library_locations.grouped_attributes(" Emergency -|- Kittenz ")).to eq ["Kittenz"]
    end
  end

  describe LibraryLocations::LocationInfo do
    let(:doc) {[["CHEMCHMENG"], "123 -|- CHEMCHMENG"]}
    let(:library_info) { LibraryLocations::LocationInfo.new(doc) }
    it "should initialize a new reservation" do
      expect(library_info).to be_an LibraryLocations::LocationInfo
    end

    it "should have the correct location" do
      expect(library_info.library).to eq "CHEMCHMENG"
    end

    it "should be viewable" do
      expect(library_info.is_viewable?).to be_true
    end

    it "should not be viewable" do
      expect(LibraryLocations::LocationInfo.new([["PHYSICS"], "123 -|- PHYSICS"]).is_viewable?).to be_false
    end
  end
end
