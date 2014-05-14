require "spec_helper"

describe AccessPanel::Online do
  include Marc856Fixtures
  let(:fulltext) { Online.new(SolrDocument.new(marcxml: fulltext_856)) }
  let(:supplemental) { Online.new(SolrDocument.new(marcxml: supplemental_856)) }
  it "should delegate present? to links" do
    expect(fulltext).to be_present
    expect(supplemental).to_not be_present
  end
  describe "#links" do
    it "should return fulltext links" do
      expect(fulltext.links.all?(&:fulltext?)).to be_true
    end
    it "should not return any non-fulltext links" do
      expect(supplemental.links).to be_blank
    end
  end
end
