require 'spec_helper'
require 'library_location'

describe LibraryLocation do
  let(:non_present_library_doc) {
    SolrDocument.new(
      id: '123',
      item_display: ["36105217238315 -|- SUL -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"]
    )
  }
  describe "#libraries" do
    let(:doc) {
      SolrDocument.new(
        id: '123',
        item_display: [
          "36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011",
          "36105217238315 -|- SUL -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"
        ]
      )
    }
    it "should only return present libraries" do
      expect(LibraryLocation.new(doc).libraries.length).to eq 1
    end
  end
  describe "present?" do
    it "should return false if the document only contains non-present libraries" do
      expect(LibraryLocation.new(non_present_library_doc)).to_not be_present
    end
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
