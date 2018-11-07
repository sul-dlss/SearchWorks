require "spec_helper"

describe MarcLinks do
  include Marc856Fixtures
  it "should return an empty array for non marc records" do
    expect( SolrDocument.new.marc_links.all).to eq []
  end

  describe 'with a SolrDocument with structured data extracted from the marc' do
    let(:document) do
      SolrDocument.new(marc_links_struct: [
        { text: 'fulltext', fulltext: true },
        { text: 'stanford only',  stanford_only: true },
        { html: 'finding aid', finding_aid: true },
        { text: 'druid', managed_purl: true, file_id: 'x', druid: 'abc' },
      ])
    end

    it 'decodes structured data in the document' do
      expect(document.marc_links.all.length).to eq 4
      expect(document.marc_links.fulltext.first.text).to eq 'fulltext'
      expect(document.marc_links.finding_aid.first.html).to eq 'finding aid'
      expect(document.marc_links.supplemental.first).to be_stanford_only
      expect(document.marc_links.managed_purls.first.text).to eq 'druid'
      expect(document.marc_links.managed_purls.first.file_id).to eq 'x'
      expect(document.marc_links.managed_purls.first.druid).to eq 'abc'
    end
  end
end
