require 'spec_helper'
require 'access_panels/library_location'

describe AccessPanels::LibraryLocation do
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
    it "should only return the libraries" do
      expect(described_class.new(doc).libraries.length).to eq 2
    end
  end
  describe "present?" do
    it "should have a library location present" do
      doc = SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"])
      expect(described_class.new(doc).present?).to eq true
    end

    it "should not have a library location present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(doc).present?).to eq false
    end
  end
end
