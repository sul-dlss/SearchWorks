require "spec_helper"

describe "catalog/access_panels/_location.html.erb", js:true do
  include MarcMetadataFixtures
  describe "non location record" do
    before do
      assign(:document, SolrDocument.new)
    end
    it "should not render any panel" do
      render
      expect(rendered).to be_blank
    end
  end
  describe "object with a location" do
    it "should render the panel" do
      assign(:document, SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"]))
      render
      expect(rendered).to have_css(".panel-library-location")
      expect(rendered).to have_css(".library-location-heading")
      expect(rendered).to have_css(".library-location-heading-text a", text: "Earth Sciences Library (Branner)")
      expect(rendered).to have_css("div.location-hours-today")
      expect(rendered).to have_css(".panel-body")
    end
  end
  describe "bound with locations" do
    before do
      assign(:document, SolrDocument.new(
        id: '1234',
        item_display: ['1234 -|- SAL3 -|- SEE-OTHER -|- -|- -|- -|- -|- -|- ABC 123'],
        marcxml: linked_ckey_fixture
      ))
      render
    end
    it "should display the MARC 590 as a bound with note" do
      expect(rendered).to have_css('p.bound-with-note.note-highlight', text: 'Copy 1 bound with v. 140 55523 (parent record’s ckey)')
      expect(rendered).to have_css('p.bound-with-note.note-highlight a', text: '55523')
    end
    it "should not display request links for requestable libraries" do
      expect(rendered).to_not have_content("Request")
    end
  end
  describe "status text" do
    before do
      assign(:document, SolrDocument.new(
        id: '123',
        item_display: [
          '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123',
          '321 -|- SPEC-COLL -|- STACKS -|- -|- -|- -|- -|- -|- ABC 321'
        ]
      ))
      render
    end
    it "should have screen-reader-only unknown status text for items we'll be looking up" do
      expect(rendered).to have_css('.status-text.sr-only', text: 'Unknown')
    end
    it "should have explicit screen-reader-only status text for items that we know the status" do
      expect(rendered).to have_css('.status-text.sr-only', text: 'In-library use')
    end
  end
  describe "current locations" do
    it "should be displayed" do
      assign(:document, SolrDocument.new(
        id: '123',
        item_display: ['123 -|- GREEN -|- STACKS -|- INPROCESS -|- -|- -|- -|- -|- ABC 123']
      ))
      render
      expect(rendered).to have_css('.current-location', text: 'In process')
    end
    describe "as home location" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['123 -|- ART -|- STACKS -|- IC-DISPLAY -|- -|- -|- -|- -|- ABC 123']
        ))
        render
      end
      it "should display the current location as the home location" do
        expect(rendered).to_not have_css('.location-name', text: "Stacks")
        expect(rendered).to have_css('.location-name', text: "InfoCenter: display")
      end
      it "should not be displayed if the current location is a special location that gets treated like a home location" do
        expect(rendered).to have_css('.current-location', text: '')
      end
    end
    describe "is reserve desk" do
      it "should use the library of the owning reserve desk" do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['123 -|- ART -|- STACKS -|- GREEN-RESV -|- -|- -|- -|- -|- ABC 123']
        ))
        render
        expect(rendered).to have_css('.library-location-heading-text a', text: 'Green Library')
      end
    end
  end
  describe "mhld" do
    describe "with matching library/location" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['321 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123'],
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        ))
        render
      end
      it "should include the matched MHLD" do
        expect(rendered).to have_css('h3 a', text: "Green Library", count: 1)
        expect(rendered).to have_css('li .location-name', text: "Stacks", count: 1)
        expect(rendered).to have_css('ul.items li.mhld', text: "public note")
        expect(rendered).to have_css('ul.items li.mhld.note-highlight', text: "Latest: latest received")
        expect(rendered).to have_css('ul.items li.mhld', text: "Library has: library has")
        expect(rendered).to have_css('ul.items li', text: "ABC 123")
      end
    end
    describe "that has no matching library/location" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        ))
        render
      end
      it "should invoke a library block w/ the appropriate mhld data" do
        expect(rendered).to have_css('h3 a', text: "Green Library")
        expect(rendered).to have_css('li .location-name', text: "Stacks")
        expect(rendered).to have_css('ul.items li.mhld', text: "public note")
        expect(rendered).to have_css('ul.items li.mhld.note-highlight', text: "Latest: latest received")
        expect(rendered).to have_css('ul.items li.mhld', text: "Library has: library has")
      end
    end
  end
  describe "request links" do
    describe "location level request links" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['123 -|- SAL -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123']
        ))
        render
      end
      it "should be present" do
        expect(rendered).to have_css('ul.location li a', text: 'Request')
      end
      it "should not have any requestable items" do
        expect(rendered).to_not have_css('ul.items li[data-request-url]')
      end
    end
    describe "item level request links" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['123 -|- GREEN -|- STACKS -|- MISSING -|- -|- -|- -|- -|- ABC 123']
        ))
        render
      end
      it "should not have a request url stored in the data attribute" do
        expect(rendered).to_not have_css('ul.items li[data-request-url]')
      end
      it "should not have a request link in the item" do
        expect(rendered).to have_css('ul.items li a', text: 'Request')
      end
    end
    describe "requestable vs. non-requestable items" do
      before do
        assign(:document, SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- NH-SOMETHING -|- -|- -|- -|- ABC 123',
            '456 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 456'
          ]
        ))
        render
      end
      it "should have an item that has a request url" do
        expect(rendered).to have_css('ul.items li[data-request-url]', text: 'ABC 456')
      end
      it "should have an item that does not have a request url" do
        expect(rendered).to_not have_css('ul.items li[data-request-url]', text: 'ABC 123')
      end
    end
  end
  describe "zombie libraries" do
    before do
      assign(:document, SolrDocument.new(
        id: '123',
        item_display: [
          "123 -|- SUL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-",
          "456 -|- PHYSICS -|- PHYSTEMP -|- -|- -|- -|- -|- -|- DEF -|-",
          "789 -|- -|- ON-ORDER -|- ON-ORDER -|- -|- -|- -|- -|- GHI -|-"
        ]
      ))
      render
    end
    it "should render a zombie library" do
      expect(rendered).to have_css('.panel-library-location', count: 1)
    end
    it "should render SUL items in the zombie library" do
      expect(rendered).to have_css('.panel-library-location li', text: 'ABC')
    end
    it "should render PHYSICS items in the zombie library" do
      expect(rendered).to have_css('.panel-library-location li', text: 'DEF')
    end
    it "should render blank (i.e. on order) items in the zombie library" do
      expect(rendered).to have_css('.panel-library-location li', text: 'GHI')
    end
  end
  describe 'public note' do
    before do
      assign(:document, SolrDocument.new(
          id: '123',
          item_display: ['123 -|- SUL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|- -|- this is public']
        ))
      render
    end
    it 'should render public note' do
      expect(rendered).to have_css('div.public-note.note-highlight', text: 'Note: this is public')
    end
  end
end
