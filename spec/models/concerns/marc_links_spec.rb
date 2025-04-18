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
        { link_text: 'druid', managed_purl: true, file_id: 'x', druid: 'abc' }
      ])
    end

    it 'decodes structured data in the document' do
      expect(document.marc_links.all.length).to eq 4
      expect(document.marc_links.fulltext.first.text).to eq 'fulltext'
      expect(document.marc_links.finding_aid.first.html).to eq '<a href="http://oac.cdlib.org/findai/ark:/13030/an-ark">Online Archive of California</a>'
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
        expect(marc_links.first.html).to match(%r{^<a href="https://library\.stanford\.edu"})
        expect(marc_links.last.html).to match(%r{^<a href="https://searchworks\.stanford\.edu">link text</a>$})
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
          expect(document.marc_links.finding_aid.first.html).to match(
            %r{<a href=".*oac\.cdlib\.org/findaid/ark:/something-else">Online Archive of California</a>}
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
          expect(document.marc_links.finding_aid.first.html).to match(
            %r{<a href=".*archives\.stanford\.edu/findaid/ark:/archives-ark-id">Archival Collections at Stanford</a>}
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
          expect(marc_links.first.html).to match(
            %r{<a href=.*example\.com/lookup\?\^The\+Query.*>www\.example\.com</a>}
          )
          expect(marc_links[2].html).to match(%r{<a.*> at: </a>})
        end
      end

      context 'with SFX links' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://example.com/sfx-link", sfx: true }]
          )
        end

        it 'identifies sfx URLs and link them appropriately' do
          expect(marc_links.length).to eq 1
          expect(marc_links.first).to be_sfx
          expect(document.marc_links.sfx.length).to eq 1
          expect(document.marc_links.sfx.first).to be_sfx
          expect(document.marc_links.sfx.first.html).to match(%r{^<a href=.*class="sfx">Find full text</a>$})
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
            expect(marc_links.first.html).to match(%r{<a href=.*>library\.stanford\.edu</a>})
            expect(marc_links.last.html).to match(%r{<a href=.*>ezproxy\.stanford\.edu</a>})
          end
        end

        context 'LANE records with a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://www.who.int/whatever",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Access restricted to Stanford community' }],
              holdings_library_code_ssim: ['LANE']
            )
          end

          it 'prefixes the link with the ezproxy URL' do
            expect(marc_links.first.href).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwww.who.int%2Fwhatever'
          end
        end

        context 'LANE records without a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://www.who.int/whatever", fulltext: true, stanford_only: true }],
              holdings_library_code_ssim: ['LANE']
            )
          end

          it 'leaves the url alone' do
            expect(marc_links.first.href).to eq 'https://www.who.int/whatever'
          end
        end

        context 'LAW records with a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://www.iareporter.com/whatever",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to Stanford Law School' }],
              holdings_library_code_ssim: ['LAW']
            )
          end

          it 'prefixes the link with the ezproxy URL' do
            expect(marc_links.first.href).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
          end
        end

        context 'LAW records without a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://www.iareporter.com/whatever", fulltext: true, stanford_only: true }],
              holdings_library_code_ssim: ['LAW']
            )
          end

          it 'prefixes the link with the ezproxy URL' do
            expect(marc_links.first.href).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
          end
        end

        context 'SUL records with a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to stanford-affiliated users.' }]
            )
          end

          it 'prefixes the link with the ezproxy URL' do
            expect(marc_links.first.href).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end

        context 'SUL records without a link_title/856$z restricted note' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever", fulltext: true, stanford_only: true }]
            )
          end

          it 'leaves the url alone' do
            expect(marc_links.first.href).to eq 'http://ch.ucpress.edu/whatever'
          end
        end

        context 'a url that matches a LANE ezproxy host for a SUL item' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "https://www.who.int/whatever",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to stanford-affiliated users.' }]
            )
          end

          it 'leaves the url alone' do
            expect(marc_links.first.href).to eq 'https://www.who.int/whatever'
          end
        end

        context 'a url that matches a SUL ezproxy host for a LANE item' do
          let(:document) do
            SolrDocument.new(
              marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever",
                                    fulltext: true,
                                    stanford_only: true,
                                    link_title: 'Available to stanford-affiliated users.' }],
              holdings_library_code_ssim: ['LANE']
            )
          end

          it 'prefixes the link with the SUL url' do
            expect(marc_links.first.href).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
          end
        end
      end
    end
  end
end
