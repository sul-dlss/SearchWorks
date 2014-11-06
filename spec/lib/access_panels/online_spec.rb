require "spec_helper"

describe AccessPanel::Online do
  include ModsFixtures
  include Marc856Fixtures
  let(:fulltext) { Online.new(SolrDocument.new(marcxml: fulltext_856)) }
  let(:supplemental) { Online.new(SolrDocument.new(marcxml: supplemental_856)) }
  let(:sfx) { Online.new(
    SolrDocument.new(url_sfx: 'http://example.com/sfx-link', marcxml: fulltext_856)
  ) }
  let(:image_collection_member) {
    Online.new(
      SolrDocument.new(
        collection: ['12345'],
        url_fulltext: 'http://library.stanford.edu'
      )
    )
  }
  let(:mods) { Online.new(
    SolrDocument.new(
      collection: ['12345'],
      url_fulltext: 'http://purl.stanford.edu/',
      modsxml: mods_everything
    )
  ) }
  it "should delegate present? to links" do
    expect(fulltext).to be_present
    expect(supplemental).to_not be_present
  end
  describe "#links" do
    it "should not return links when they are present in MODS records" do
      expect(mods.links).to_not be_present
    end
    it "should return fulltext links" do
      expect(fulltext.links.all?(&:fulltext?)).to be_true
    end
    it "should return the SFX link even if there are other links" do
      links = sfx.links
      expect(links.length).to eq 1
      expect(links.first).to be_sfx
      expect(links.first.html).to match /^<a href=.*class='sfx'>Find full text<\/a>$/
    end
    it 'should not return fulltext links from the index for collection members' do
      expect(image_collection_member.links).to_not be_present
    end
    it "should not return any non-fulltext links" do
      expect(supplemental.links).to be_blank
    end
  end
end
