require 'rails_helper'

RSpec.describe MarcLinks do
  it "should return an empty array for non marc records" do
    expect(SolrDocument.new.marc_links.all).to eq []
  end

  describe 'with a SolrDocument with structured data extracted from the marc' do
    let(:document) do
      SolrDocument.new(marc_links_struct: [
        { link_text: 'fulltext', fulltext: true },
        { link_text: 'stanford only',  stanford_only: true },
        { href: 'http://example.com', link_text: 'finding aid', finding_aid: true },
        { link_text: 'druid', managed_purl: true, file_id: 'x', druid: 'abc' }
      ])
    end

    it 'decodes structured data in the document' do
      expect(document.marc_links.all.length).to eq 4
      expect(document.marc_links.fulltext.first.text).to eq 'fulltext'
      expect(document.marc_links.finding_aid.first.html).to eq '<a href="http://example.com">finding aid</a>'
      expect(document.marc_links.supplemental.first).to be_stanford_only
      expect(document.marc_links.managed_purls.first.text).to eq 'druid'
      expect(document.marc_links.managed_purls.first.file_id).to eq 'x'
      expect(document.marc_links.managed_purls.first.druid).to eq 'abc'
    end
  end

  describe 'ezproxy' do
    context 'SUL records' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{
            href: 'http://ch.ucpress.edu/whatever',
            link_title: 'Available to Stanford-affiliated users.'
          }]
        )
      end

      it 'prefixes the link with the ezproxy URL' do
        expect(document.marc_links.all.first.href).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
      end
    end
  end
end
