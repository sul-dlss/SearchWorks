# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccessPanels::OnlineComponent, type: :component do
  include ModsFixtures

  let(:fulltext) { described_class.new(document: SolrDocument.new(marc_links_struct: [{ link_text: "Link text", href: "https://library.stanford.edu", fulltext: true }])) }
  let(:supplemental) { described_class.new(document: SolrDocument.new) }
  let(:eds_links) do
    described_class.new(
      document: EdsDocument.new(
        'FullText' => {
          'CustomLinks' => [
            { 'Text' => 'HTML full text', 'Url' => 'http://example.com' }
          ]
        }
      )
    )
  end

  let(:sfx) do
    described_class.new(
      document: SolrDocument.new(
        marc_links_struct: [{ link_text: "Link text", href: "http://example.com/sfx-link", sfx: true }]
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
    it 'does not return links when they are present in MODS records' do
      expect(mods.links).not_to be_present
    end

    it 'returns fulltext links' do
      expect(fulltext.links.all?(&:fulltext?)).to be_truthy
    end

    it 'returns the SFX link even if there are other links' do
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

    it 'does not return any non-fulltext links' do
      expect(supplemental.links).to be_blank
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
        { marc_links_struct: [{ fulltext: 'true' }], format_hsim: ['Database'] }
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

    it "renders nothing" do
      render_inline(described_class.new(document:))
      expect(page).to have_no_css(".panel-online")
    end
  end

  describe "marc record" do
    it "renders the panel with a link" do
      document = SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }])
      render_inline(described_class.new(document:))
      expect(page).to have_css(".panel-online")
      expect(page).to have_css("h2", text: "Online")
      expect(page).to have_css("ul.links li a", text: "Link text")
    end
    it 'adds the stanford-only icon to Stanford only resources' do
      document = SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', additional_text: '4 at one time', fulltext: true, stanford_only: true }])
      render_inline(described_class.new(document:))
      expect(page).to have_css(".panel-online")
      expect(page).to have_css("ul.links li .stanford-only")
      expect(page).to have_css("span.additional-link-text", text: "4 at one time")
    end
    it 'renders a different heading for SDR items' do
      document = SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }], druid: 'ng161qh7958')
      render_inline(described_class.new(document:))
      expect(page).to have_css '.panel-online'
      expect(page).to have_css 'h2', text: 'Also available at'
    end

    context 'when the record has an SFX link' do
      it 'renders markup w/ attributes to fetch SFX data (and does not render the link)' do
        document = SolrDocument.new(marc_links_struct: [link_text: "Link text", href: "http://example.com/sfx-link", sfx: true])
        render_inline(described_class.new(document:))
        expect(page).to have_css('.panel-online')
        expect(page).to have_no_link('Find full text')
        expect(page).to have_css('turbo-frame#sfx-data')
      end
    end

    describe "database" do
      let(:document) do
        SolrDocument.new(marc_links_struct: [{ href: '...', link_text: 'Link text', fulltext: true }], format_hsim: ["Database"])
      end

      it "renders a special card heading" do
        render_inline(described_class.new(document:))
        expect(page).to have_css("h2", text: "Search this database")
      end
      it "renders a special card footer" do
        render_inline(described_class.new(document:))
        expect(page).to have_link("Report a connection problem")
      end
    end
  end
end
