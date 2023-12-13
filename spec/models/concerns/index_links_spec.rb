require 'rails_helper'

RSpec.describe IndexLinks do
  let(:document) do
    SolrDocument.new(
      marc_links_struct: [{ href: "https://library.stanford.edu", fulltext: true, stanford_only: true },
                          { link_text: "link text", href: "https://searchworks.stanford.edu" }]
    )
  end

  describe 'mixin' do
    it 'should add the #index_links method' do
      expect(document).to respond_to(:index_links)
    end
    it '#index_links should return Links' do
      expect(document.index_links).to be_a(Links)
      document.index_links.each do |index_link|
        expect(index_link).to be_a Links::Link
      end
    end
  end

  describe 'Links' do
    let(:index_links) { document.index_links }

    it 'returns both fulltext and supplemental links' do
      expect(index_links.all.length).to eq 2
      expect(index_links.all.first.html).to match(%r{^<a.*>library\.stanford\.edu<\/a>$})
      expect(index_links.all.last.html).to match(%r{^<a.*>searchworks\.stanford\.edu<\/a>$})
    end

    it 'returns the plain text and href separately' do
      expect(index_links.all.length).to eq 2
      expect(index_links.all.first.text).to eq 'library.stanford.edu'
      expect(index_links.all.first.href).to eq 'https://library.stanford.edu'
      expect(index_links.all.last.text).to eq 'searchworks.stanford.edu'
      expect(index_links.all.last.href).to eq 'https://searchworks.stanford.edu'
    end

    it 'identifies urls that are in the url_restricted field as stanford only' do
      expect(index_links.all.first).to be_stanford_only
      expect(index_links.all.last).not_to be_stanford_only
    end

    it 'identifies urls that are in the url_fulltext field as fulltext' do
      expect(index_links.all.first).to be_fulltext
      expect(index_links.all.last).not_to be_fulltext
    end

    context 'with an OAC finding aid' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{ href: "http://oac.cdlib.org/findaid/ark:/something-else", finding_aid: true }]
        )
      end

      it 'identifies finding aid links' do
        expect(index_links.all.first).to be_finding_aid
        expect(index_links.finding_aid.length).to eq 1
        expect(index_links.finding_aid.first.html).to match(
          %r{<a href=".*oac\.cdlib\.org\/findaid\/ark:\/something-else">Online Archive of California<\/a>}
        )
      end
    end

    context 'with an OAC finding aid using an alternative format' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{ href: "http://oac.cdlib.org/ark:/something-else", finding_aid: true }]
        )
      end

      it 'identifies finding aid links' do
        expect(index_links.all.first).to be_finding_aid
      end
    end

    context 'with a managed purl' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{ href: "https://purl.stanford.edu/abc123", managed_purl: true }]
        )
      end

      it 'identifies managed purls' do
        expect(index_links.all.length).to eq 1
        expect(index_links.managed_purls.length).to eq 1
        expect(index_links.all.first).to eq(index_links.managed_purls.first)
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
        expect(index_links.all.length).to eq 4
        expect(index_links.all.first.html).to match(
          %r{<a href=.*example\.com\/lookup\?\^The\+Query.*>www\.example\.com<\/a>}
        )
        expect(index_links.all[2].html).to match(%r{<a.*> at: <\/a>})
      end
    end

    context 'with SFX links' do
      let(:document) do
        SolrDocument.new(
          marc_links_struct: [{ href: "http://example.com/sfx-link", sfx: true }]
        )
      end

      it 'identifies sfx URLs and link them appropriately' do
        expect(index_links.all.length).to eq 1
        expect(index_links.all.first).to be_sfx
        expect(index_links.sfx.length).to eq 1
        expect(index_links.sfx.first).to be_sfx
        expect(index_links.sfx.first.html).to match(%r{^<a href=.*class="sfx">Find full text<\/a>$})
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
          expect(index_links.all.length).to eq 2
          expect(index_links.all.first.html).to match(%r{<a href=.*>library\.stanford\.edu<\/a>})
          expect(index_links.all.last.html).to match(%r{<a href=.*>ezproxy\.stanford\.edu<\/a>})
        end
      end

      context 'LANE records with a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://who.int/whatever",
                                  fulltext: true,
                                  stanford_only: true,
                                  link_title: 'Access restricted to Stanford community' }],
            item_display_struct: [{ barcode: 'barcode', library: 'LANE-MED' }]
          )
        end

        it 'prefixes the link with the ezproxy URL' do
          expect(document.index_links.all.first.href).to eq 'https://login.laneproxy.stanford.edu/login?qurl=https%3A%2F%2Fwho.int%2Fwhatever'
        end
      end

      context 'LANE records without a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://who.int/whatever", fulltext: true, stanford_only: true }],
            item_display_struct: [{ barcode: 'barcode', library: 'LANE-MED' }]
          )
        end

        it 'leaves the url alone' do
          expect(document.index_links.all.first.href).to eq 'https://who.int/whatever'
        end
      end

      context 'LAW records with a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://www.iareporter.com/whatever",
                                  fulltext: true,
                                  stanford_only: true,
                                  link_title: 'Available to Stanford Law School' }],
            item_display_struct: [{ barcode: 'barcode', library: 'LAW' }]
          )
        end

        it 'prefixes the link with the ezproxy URL' do
          expect(document.index_links.all.first.href).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end

      context 'LAW records without a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://www.iareporter.com/whatever", fulltext: true, stanford_only: true }],
            item_display_struct: [{ barcode: 'barcode', library: 'LAW' }]
          )
        end

        it 'prefixes the link with the ezproxy URL' do
          expect(document.index_links.all.first.href).to eq 'https://ezproxy.law.stanford.edu/login?qurl=https%3A%2F%2Fwww.iareporter.com%2Fwhatever'
        end
      end

      context 'SUL records with a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever",
                                  fulltext: true,
                                  stanford_only: true,
                                  link_title: 'Available to stanford-affiliated users.' }],
            item_display_struct: [{ barcode: 'barcode', library: 'GREEN' }]
          )
        end

        it 'prefixes the link with the ezproxy URL' do
          expect(document.index_links.all.first.href).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
        end
      end

      context 'SUL records without a link_title/856$z restricted note' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever", fulltext: true, stanford_only: true }],
            item_display_struct: [{ barcode: 'barcode', library: 'GREEN' }]
          )
        end

        it 'leaves the url alone' do
          expect(document.index_links.all.first.href).to eq 'http://ch.ucpress.edu/whatever'
        end
      end

      context 'a url that matches a LANE-MED ezproxy host for a SUL item' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "https://who.int/whatever",
                                  fulltext: true,
                                  stanford_only: true,
                                  link_title: 'Available to stanford-affiliated users.' }],
            item_display_struct: [{ barcode: 'barcode', library: 'GREEN' }]
          )
        end

        it 'leaves the url alone' do
          expect(document.index_links.all.first.href).to eq 'https://who.int/whatever'
        end
      end

      context 'a url that matches a SUL ezproxy host for a LANE item' do
        let(:document) do
          SolrDocument.new(
            marc_links_struct: [{ href: "http://ch.ucpress.edu/whatever",
                                  fulltext: true,
                                  stanford_only: true,
                                  link_title: 'Available to stanford-affiliated users.' }],
            item_display_struct: [{ barcode: 'barcode', library: 'LANE-MED' }]
          )
        end

        it 'prefixes the link with the SUL url' do
          expect(document.index_links.all.first.href).to eq 'https://stanford.idm.oclc.org/login?qurl=http%3A%2F%2Fch.ucpress.edu%2Fwhatever'
        end
      end
    end
  end
end
