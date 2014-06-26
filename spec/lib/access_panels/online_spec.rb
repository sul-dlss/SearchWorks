require "spec_helper"

describe AccessPanel::Online do
  include Marc856Fixtures
  let(:fulltext) { Online.new(SolrDocument.new(marcxml: fulltext_856)) }
  let(:supplemental) { Online.new(SolrDocument.new(marcxml: supplemental_856)) }
  let(:sfx) { Online.new(
    SolrDocument.new(url_sfx: 'http://example.com/sfx-link', marcxml: fulltext_856)
  ) }
  it "should delegate present? to links" do
    expect(fulltext).to be_present
    expect(supplemental).to_not be_present
  end
  describe "#links" do
    it "should return fulltext links" do
      expect(fulltext.links.all?(&:fulltext?)).to be_true
    end
    it "should return the SFX link even if there are other links" do
      links = sfx.links
      expect(links.length).to eq 1
      expect(links.first).to be_sfx
      expect(links.first.text).to match /^<a href=.*class='sfx'>Find full text<\/a>$/
    end
    it "should not return any non-fulltext links" do
      expect(supplemental.links).to be_blank
    end
  end
end
