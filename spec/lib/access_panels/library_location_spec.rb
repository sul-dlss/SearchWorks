require 'spec_helper'
require 'library_location'

describe LibraryLocation do

  describe "present?" do

    it "should have a library location present" do
      doc = SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"])
      expect(LibraryLocation.new(doc).present?).to eq true
    end

    it "should not have a library location present" do
      doc = SolrDocument.new(id: '123')
      expect(LibraryLocation.new(doc).present?).to eq false
    end
  end
end
