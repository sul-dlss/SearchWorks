require 'rails_helper'

RSpec.describe AccessPanels::OnlineComponent, type: :component do
  include ModsFixtures
  include Marc856Fixtures

  let(:fulltext) { described_class.new(document: SolrDocument.new(marc_links_struct: [{ link_text: "Link text", href: "https://library.stanford.edu", fulltext: true }])) }
  let(:supplemental) { described_class.new(document: SolrDocument.new) }
  let(:eds_links) do
    described_class.new(
      document: SolrDocument.new(
        eds_fulltext_links: [{ 'label' => 'HTML full text', 'url' => 'http://example.com', 'type' => 'customlink-fulltext' }]
      )
    )
  end

  let(:sfx) do
    described_class.new(
      document: SolrDocument.new(
        marc_links_struct: [{ link_text: "Link text", href: "http://example.com/sfx-link", sfx: true }],
        marc_json_struct: fulltext_856
      )
    )
  end

  let(:image_collection_member) do
    described_class.new(
      document: SolrDocument.new(
        collection: ['12345'],
        marc_links_struct: [{ link_text: "Link text", href: "https://library.stanford.edu", fulltext: true }]
      )
    )
  end

  let(:managed_purl_doc) do
    described_class.new(
      document: SolrDocument.new(
        marc_links_struct: [{ link_text: "Link text", href: "https://library.stanford.edu", fulltext: true, managed_purl: true }]
      )
    )
  end

  let(:mods) do
    described_class.new(
      document: SolrDocument.new(
        collection: ['12345'],
        marc_links_struct: [{ link_text: "Link text", href: "https://purl.stanford.edu/", fulltext: true, managed_purl: true }]
      )
    )
  end

  let(:hathi_public) do
    described_class.new(
      document: SolrDocument.new(ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'], ht_access_sim: ['allow'])
    )
  end

  let(:hathi_non_public) do
    described_class.new(
      document: SolrDocument.new(ht_bib_key_ssim: ['abc123'], ht_htid_ssim: ['1234567'])
    )
  end

  describe '#render?' do
    it 'is true when there are fulltext links present' do
      render_inline(fulltext)

      expect(page).to have_css '.panel-online'
    end

    it 'is true when there are eds links present' do
      render_inline(eds_links)

      expect(page).to have_css '.panel-online'
    end

    it 'is false when there are only supplemental links present' do
      render_inline(supplemental)

      expect(page).to have_no_selector '.panel-online'
    end
  end

  describe '#links' do
    it 'should not return links when they are present in MODS records' do
      expect(mods.links).not_to be_present
    end

    it 'should return fulltext links' do
      expect(fulltext.links.all?(&:fulltext?)).to be_truthy
    end

    it 'should return the SFX link even if there are other links' do
      links = sfx.links
      expect(links.length).to eq 1
      expect(links.first).to be_sfx
      expect(links.first.html).to match %r{^<a href=.*class="sfx">Find full text<\/a>$}
    end

    it 'returns fulltext links for collection members' do
      expect(image_collection_member.links).to be_present
    end

    it 'does not return managed purls' do
      expect(managed_purl_doc.links).to be_blank
    end

    it 'should not return any non-fulltext links' do
      expect(supplemental.links).to be_blank
    end

    it 'should not return HathiTrust non-public access links' do
      expect(hathi_non_public.links).to be_blank
    end

    it 'should return HathiTrust public access links' do
      links = hathi_public.links
      expect(links.length).to eq 1
      expect(links.first.html).to match(%r{^<a.*>Full text via HathiTrust<\/a>$})
      expect(links.first).not_to be_stanford_only
    end
  end

  describe '#display_connection_problem_links?' do
    let(:solr_document_data) { {} }
    let(:document) { SolrDocument.new(solr_document_data) }
    let(:component) { described_class.new(document:) }

    context 'when a public (non-Stanford only) fulltext resource' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true' }] }
      end

      it { expect(component.display_connection_problem_links?).to be false }
    end

    context 'when given an sfx document' do
      let(:solr_document_data) do
        { marc_links_struct: [{ link_text: "Link text", href: "https://example.com/sfx", sfx: true }] }
      end

      it { expect(component.display_connection_problem_links?).to be true }
    end

    context 'when given a database' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true' }], format_main_ssim: ['Database'] }
      end

      it { expect(component.display_connection_problem_links?).to be true }
    end

    context 'when given a stanford only document' do
      let(:solr_document_data) do
        { marc_links_struct: [{ fulltext: 'true', stanford_only: true }] }
      end

      it { expect(component.display_connection_problem_links?).to be true }
    end
  end

  describe "non-marc record" do
    let(:document) do
      SolrDocument.new
    end

    it "should render nothing" do
      render_inline(described_class.new(document:))
      expect(page).to have_no_css(".panel-online")
    end
  end

  describe "marc record" do
    it "should render the panel with a link" do
      document = SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }])
      render_inline(described_class.new(document:))
      expect(page).to have_css(".panel-online")
      expect(page).to have_css(".card-header", text: "Available online")
      expect(page).to have_css("ul.links li a", text: "Link text")
    end
    it "should add the stanford-only class to Stanford only resources" do
      document = SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', additional_text: '4 at one time', fulltext: true, stanford_only: true }])
      render_inline(described_class.new(document:))
      expect(page).to have_css(".panel-online")
      expect(page).to have_css("ul.links li span.stanford-only")
      expect(page).to have_css("span.additional-link-text", text: "4 at one time")
    end
    it 'renders a different heading for SDR items' do
      document = SolrDocument.new(marc_json_struct: simple_856, marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }], druid: 'ng161qh7958')
      render_inline(described_class.new(document:))
      expect(page).to have_css '.panel-online'
      expect(page).to have_css '.card-header', text: 'Also available at'
    end

    context 'when the record has an SFX link' do
      it 'renders markup w/ attributes to fetch SFX data (and does not render the link)' do
        document = SolrDocument.new(marc_links_struct: [link_text: "Link text", href: "http://example.com/sfx-link", sfx: true],
                                    marc_json_struct: simple_856)
        render_inline(described_class.new(document:))
        expect(page).to have_css('.panel-online')
        expect(page).to have_no_link('Find full text')
        expect(page).to     have_css('[data-behavior="sfx-panel"]')
        expect(page).to     have_link('See the full find it @ Stanford menu')
      end
    end

    describe 'when the record is not online, has an SFX link, but may return a GBS link (due to a standard number)' do
      it 'renders content to be filled by GBS if something is returned' do
        document = SolrDocument.new(oclc: ['abc123'])
        render_inline(described_class.new(document:))

        expect(page).to have_css('.panel-online', visible: false)
        expect(page).to have_css('.panel-online .google-books.OCLCabc123', visible: false)
      end
    end

    describe "database" do
      let(:document) do
        SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }], format_main_ssim: ["Database"])
      end

      it "should render a special card heading" do
        render_inline(described_class.new(document:))
        expect(page).to have_css(".card-header", text: "Search this database")
      end
      it "should render a special card footer" do
        render_inline(described_class.new(document:))
        expect(page).to have_css(".card-footer a", text: "Report a connection problem")
      end
    end
  end
end
