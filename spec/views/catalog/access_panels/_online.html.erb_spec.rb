require "spec_helper"

describe "catalog/access_panels/_online.html.erb" do
  include Marc856Fixtures
  describe "non-marc record" do
    before do
      assign(:document, SolrDocument.new)
    end
    it "should render the panel hidden" do
      render
      expect(rendered).to have_css("div.panel-online", visible:false)
    end
  end
  describe "marc record" do
    it "should render the panel with a link" do
      assign(:document, SolrDocument.new(marcxml: simple_856))
      render
      expect(rendered).to have_css(".panel-online")
      expect(rendered).to have_css(".panel-heading", text: "Available online")
      expect(rendered).to have_css("ul.links li a", text: "Link text")
    end
    it "should add the stanford-only class to Stanford only resources" do
      assign(:document, SolrDocument.new(marcxml: stanford_only_856))
      render
      expect(rendered).to have_css(".panel-online")
      expect(rendered).to have_css("ul.links li span.stanford-only")
      expect(rendered).to have_css("span.additional-link-text", text: "4 at one time")
      expect(rendered).to have_css("a[title='Available to Stanford-affiliated users only']", text: "Link text", count: 3)
    end
    it 'renders a different heading for SDR items' do
      assign(:document, SolrDocument.new(marcxml: simple_856, druid: 'ng161qh7958'))
      render
      expect(rendered).to have_css '.panel-online'
      expect(rendered).to have_css '.panel-heading', text: 'Also available at'
    end

    context 'when the record has an SFX link' do
      it 'renders markup w/ attributes to fetch SFX data (and does not render the link)' do
        assign(:document, SolrDocument.new(url_sfx: ['http://example.com/sfx-link'], marcxml: simple_856))
        render
        expect(rendered).to     have_css('.panel-online')
        expect(rendered).to_not have_link('Find full text')
        expect(rendered).to     have_css('[data-behavior="sfx-panel"]')
        expect(rendered).to     have_link('See the full find it @ Stanford menu')
      end
    end

    describe "database" do
      before do
        assign(:document, SolrDocument.new(marcxml: simple_856, format_main_ssim: ["Database"]))
      end
      it "should render a special panel heading" do
        render
        expect(rendered).to have_css(".panel-heading", text: "Search this database")
      end
      it "should render a special panel footer" do
        render
        expect(rendered).to have_css(".panel-footer a", text: "Connect from off campus")
        expect(rendered).to have_css(".panel-footer a", text: "Report a connection problem")
      end
    end
  end
end
