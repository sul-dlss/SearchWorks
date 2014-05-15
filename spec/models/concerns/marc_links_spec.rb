require "spec_helper"

class MarcLinksTestClass
  include MarcLinks
end

describe MarcLinks do
  include Marc856Fixtures
  it "should return nil for non marc records" do
    expect(MarcLinksTestClass.new.marc_links).to be_nil
  end
  describe "link text" do
    let(:document) { SolrDocument.new(marcxml: simple_856) }
    let(:no_label_document) { SolrDocument.new(marcxml: labelless_856) }
    let(:link_text) { document.marc_links.all.first.text }
    it "should place the $3 before the link" do
      expect(link_text).to match /^Before text/
    end
    it "should place the $y as the link text" do
      expect(link_text).to match /<a.*>Link text<\/a>/
    end
    it "should place the $z as the link title attribute" do
      expect(link_text).to match /<a.*title='Title text1 Title text2'.*>/
    end
    it "should use the host of the URL if no text is available" do
      expect(no_label_document.marc_links.all.first.text).to match /<a.*>library.stanford.edu<\/a>/
    end
  end
  describe "casalini links" do
    let(:document) { SolrDocument.new(marcxml: casalini_856) }
    let(:link_text) { document.marc_links.all.first.text }
    it "should not have any text before the link" do
      expect(link_text).to match /^<a /
    end
    it "should place $3 as the link text" do
      expect(link_text).to match /<a.*>Link text<\/a>/
    end
    it "should place '(source: Casalini)' after the link" do
      expect(link_text).to match /<\/a> \(source: Casalini\)/
    end
  end
  describe "stanford_only?" do
    let(:document) { SolrDocument.new(marcxml: stanford_only_856) }
    let(:links) { document.marc_links.all }
    it "should identify all the permutations of the Stanford Only string as Stanford Only resources" do
      expect(links).to be_present
      expect(links.all?(&:stanford_only?)).to be_true
    end
  end
  describe "fulltext?" do
    let(:document) { SolrDocument.new(marcxml: fulltext_856) }
    let(:links) { document.marc_links.all }
    it "method should return all fulltext links" do
      expect(links).to eq document.marc_links.fulltext
    end
    it "should identify fulltext links" do
      expect(links).to be_present
      expect(links.all?(&:fulltext?)).to be_true
    end
  end
  describe "#supplemental" do
    let(:document) {  SolrDocument.new(marcxml: supplemental_856) }
    let(:links) { document.marc_links.all }
    it "method should return all supplemental links" do
      expect(links).to eq document.marc_links.supplemental
    end
    it "should identify supplemental links" do
      expect(links).to be_present
      expect(links.any?(&:fulltext?)).to be_false
    end
  end
  describe "ez-proxy" do
    let(:document) { SolrDocument.new(marcxml: ez_proxy_856 ) }
    let(:links) { document.marc_links.all }
    it "should place the host of the url parameter as link text of no explicit label is available" do
      expect(links.first.text).to match /<a.*>library.stanford.edu<\/a/
    end
  end
end
