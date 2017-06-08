require "spec_helper"

class MarcLinksTestClass
  include MarcLinks
end

describe MarcLinks do
  include Marc856Fixtures
  it "should return nil for non marc records" do
    expect(MarcLinksTestClass.new.marc_links).to be_nil
  end
  describe "link html, text, and href" do
    let(:document) { SolrDocument.new(marcxml: simple_856) }
    let(:no_label_document) { SolrDocument.new(marcxml: labelless_856) }
    let(:link_html) { document.marc_links.all.first.html }
    let(:link_text) { document.marc_links.all.first.text }
    let(:link_href) { document.marc_links.all.first.href }
    it "should place the $3 and $y as the link text" do
      expect(link_html).to match /<a.*>Link text 1 Link text 2<\/a>/
    end
    it "should place the $z as the link title attribute" do
      expect(link_html).to match /<a.*title='Title text1 Title text2'.*>/
    end
    it "should use the host of the URL if no text is available" do
      expect(no_label_document.marc_links.all.first.html).to match /<a.*>library.stanford.edu<\/a>/
    end
    it 'should include the plain text version' do
      expect(link_text).to eq "Link text 1 Link text 2"
    end
    it 'should include the href' do
      expect(link_href).to eq "https://library.stanford.edu"
    end
  end
  describe "casalini links" do
    let(:document) { SolrDocument.new(marcxml: casalini_856) }
    let(:link_text) { document.marc_links.all.first.html }
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
      expect(links.all?(&:stanford_only?)).to be_truthy
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
      expect(links.all?(&:fulltext?)).to be_truthy
    end
  end

  describe 'managed_purl?' do
    let(:document) { SolrDocument.new(marcxml: managed_purl_856, managed_purl_urls: ['https://library.stanford.edu']) }
    let(:links) { document.marc_links }

    it 'should return the managed purl links' do
      expect(links.all).to be_present
      expect(links.managed_purls).to be_present
      expect(links.all).to eq(links.managed_purls)
      expect(links.all.all?(&:managed_purl?)).to be true
    end

    it 'should return the file_id (without "file:")' do
      expect(links.all.first.file_id).to eq 'abc123'
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
      expect(links.any?(&:fulltext?)).to be_falsey
    end
  end
  describe "#finding_aid" do
    let(:document) { SolrDocument.new(marcxml: finding_aid_856) }
    let(:links) { document.marc_links.all }
    it "should return all finding aid links" do
      expect(links).to be_present
      expect(links.all?(&:finding_aid?)).to be_truthy
      expect(links).to eq document.marc_links.finding_aid
    end
  end
  describe "ez-proxy" do
    let(:document) { SolrDocument.new(marcxml: ez_proxy_856 ) }
    let(:links) { document.marc_links.all }
    it "should place the host of the url parameter as link text of no explicit label is available" do
      expect(links.first.html).to match /<a.*>library.stanford.edu<\/a/
    end
  end
  describe "bad URLs" do
    it "should not return anything when an 856 has no $u" do
      document = SolrDocument.new(marcxml: no_url_856)
      expect(document.marc_links.all).to_not be_present
    end
  end
end
