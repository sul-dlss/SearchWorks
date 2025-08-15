# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcLinks do
  it "returns an empty array for non marc records" do
    expect(SolrDocument.new.marc_links.all).to eq []
  end

  describe 'with a SolrDocument with structured data extracted from the marc' do
    let(:document) do
      SolrDocument.new(marc_links_struct: [
        { link_text: 'fulltext', fulltext: true },
        { link_text: 'stanford only',  stanford_only: true },
        { href: 'http://oac.cdlib.org/findai/ark:/13030/an-ark', link_text: 'finding aid', note: 'this is a finding aid' },
        { link_text: 'druid', managed_purl: true, file_id: 'x', druid: 'abc', sort: 'zzz' }
      ])
    end

    it 'decodes structured data in the document' do
      expect(document.marc_links.all.length).to eq 4
      expect(document.marc_links.fulltext.first.text).to eq 'fulltext'
      expect(document.marc_links.finding_aid.first).to have_attributes href: "http://oac.cdlib.org/findai/ark:/13030/an-ark", link_text: 'Online Archive of California'
      expect(document.marc_links.supplemental.first).to be_stanford_only
      expect(document.marc_links.managed_purls.first.text).to eq 'druid'
      expect(document.marc_links.managed_purls.first.file_id).to eq 'x'
      expect(document.marc_links.managed_purls.first.druid).to eq 'abc'
      expect(document.marc_links.managed_purls.first.sort).to eq 'zzz'
    end
  end

  describe '#marc_links' do
    let(:document) do
      SolrDocument.new(
        marc_links_struct: [{ href: "https://library.stanford.edu", fulltext: true, stanford_only: true },
                            { link_text: "link text", href: "https://searchworks.stanford.edu" }]
      )
    end

    describe 'mixin' do
      it '#marc_links returns Links' do
        expect(document.marc_links).to be_a(Links)
        expect(document.marc_links).to all(be_a Links::Link)
      end
    end

    describe 'Links' do
      subject(:marc_links) { document.marc_links.all }

      it 'returns both fulltext and supplemental links' do
        expect(marc_links.length).to eq 2
        expect(marc_links.first).to have_attributes href: 'https://library.stanford.edu'
        expect(marc_links.last).to have_attributes href: 'https://searchworks.stanford.edu',
                                                   text: 'link text'
      end

      it 'returns the plain text and href separately' do
        expect(marc_links.length).to eq 2
        expect(marc_links.first.text).to eq 'library.stanford.edu'
        expect(marc_links.first.href).to eq 'https://library.stanford.edu'
        expect(marc_links.last.text).to eq 'link text'
        expect(marc_links.last.href).to eq 'https://searchworks.stanford.edu'
      end

      it 'identifies urls that are in the url_restricted field as stanford only' do
        expect(marc_links.first).to be_stanford_only
        expect(marc_links.last).not_to be_stanford_only
      end

      it 'identifies urls that are in the url_fulltext field as fulltext' do
        expect(marc_links.first).to be_fulltext
        expect(marc_links.last).not_to be_fulltext
      end

      context 'with an OAC finding aid' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://oac.cdlib.org/findaid/ark:/something-else", note: 'finding aid is here' }]
          )
        end

        it 'identifies finding aid links' do
          expect(marc_links.first).to be_finding_aid
          expect(document.marc_links.finding_aid.length).to eq 1
          expect(document.marc_links.finding_aid.first).to have_attributes(
            href: "http://oac.cdlib.org/findaid/ark:/something-else",
            link_text: 'Online Archive of California'
          )
        end
      end

      context 'with an OAC finding aid using an alternative format' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/something-else", note: 'finding aid' }]
          )
        end

        it 'identifies finding aid links' do
          expect(marc_links.first).to be_finding_aid
        end
      end

      context 'with multiple (OAC and Archives) finding aids' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: 'http://oac.cdlib.org/findaid/ark:/oac-ark-id', note: 'finding aid is here' },
                                { href: 'http://archives.stanford.edu/findaid/ark:/archives-ark-id', note: 'finding aid' }]
          )
        end

        it 'displays the preferred (Archives) finding aid' do
          expect(marc_links.first).to be_finding_aid
          expect(document.marc_links.finding_aid.length).to eq 2
          expect(document.marc_links.finding_aid.first).to have_attributes(
            href: "http://archives.stanford.edu/findaid/ark:/archives-ark-id",
            link_text: 'Archival Collections at Stanford'
          )
        end
      end

      context 'with a managed purl' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://purl.stanford.edu/abc123", managed_purl: true }]
          )
        end

        it 'identifies managed purls' do
          expect(marc_links.length).to eq 1
          expect(document.marc_links.managed_purls.length).to eq 1
          expect(marc_links.first).to eq(document.marc_links.managed_purls.first)
        end
      end

      context 'with bad links' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://www.example.com/lookup?^The+Query+Is+No+Good", fulltext: true },
                                { href: " http://www.example.com/{1234-1431324-431313}Img100.jpg ", fulltext: true },
                                { href: " at: ", fulltext: true },
                                { href: "http://Coastal erosion is widespread and locally severe in Hawaii and other low-latitude areas", fulltext: true }]
          )
        end

        it 'parses them properly' do
          expect(marc_links.length).to eq 4
          expect(marc_links.first).to have_attributes href: "http://www.example.com/lookup?^The+Query+Is+No+Good",
                                                      text: 'www.example.com'

          expect(marc_links.third).to have_attributes(text: ' at: ')
        end
      end

      describe 'ezproxy' do
        context 'pre-encoded urls' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://stanford.idm.oclc.org/login?url=https://library.stanford.edu",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to stanford-affiliated users.' },
                                  { href: "http://ezproxy.stanford.edu:2197/stable/i403360",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to stanford-affiliated users.' }]
            )
          end

          it 'returns the URL in the url parameter for ezproxy links (but fallback on the URL host)' do
            expect(marc_links.length).to eq 2
            expect(marc_links.first).to have_attributes(link_text: 'library.stanford.edu')
            expect(marc_links.last).to have_attributes(link_text: 'ezproxy.stanford.edu')
          end
        end
      end
    end
  end

  describe '#preferred_online_links' do
    it 'prioritizes non-aggregator links when EBSCO added the data' do
      document = SolrDocument.new(
        marc_links_struct: [
          { href: 'https://search.ebscohost.com/', link_text: 'EBSCOHost Link', fulltext: true },
          { href: 'https://proquest.com/aggregator', link_text: 'Aggregator Link', fulltext: true },
          { href: 'https://example.com/direct', link_text: 'Direct Link', fulltext: true }
        ]
      )

      expect(document.preferred_online_links.first.href).to eq 'https://example.com/direct'
    end

    it 'leaves the links alone if there is no EBSCO data' do
      document = SolrDocument.new(
        marc_links_struct: [
          { href: 'https://proquest.com/aggregator', link_text: 'Aggregator Link', fulltext: true },
          { href: 'https://example.com/direct', link_text: 'Direct Link', fulltext: true }
        ]
      )

      expect(document.preferred_online_links.first.href).to eq 'https://proquest.com/aggregator'
    end
  end
end
