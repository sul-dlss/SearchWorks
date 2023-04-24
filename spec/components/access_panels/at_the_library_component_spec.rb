require 'spec_helper'

RSpec.describe AccessPanels::AtTheLibraryComponent, type: :component do
  include MarcMetadataFixtures

  let(:non_present_library_doc) {
    SolrDocument.new(
      id: '123',
      item_display: ["36105217238315 -|- SUL -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"]
    )
  }

  describe "#libraries" do
    let(:doc) {
      SolrDocument.new(
        id: '123',
        item_display: [
          "36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011",
          "36105217238315 -|- SUL -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"
        ]
      )
    }

    it "should only return the libraries" do
      expect(described_class.new(document: doc).libraries.length).to eq 2
    end
  end

  describe "render?" do
    it "should have a library location present" do
      doc = SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "should not have a library location present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(document: doc).render?).to be false
    end
  end

  describe "object with a location" do
    it "should render the panel" do
      render_inline(described_class.new(document: SolrDocument.new(id: '123', item_display: ["36105217238315 -|- EARTH-SCI -|- STACKS -|-  -|- STKS -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011 -|- en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~ -|- G70.212 .A426 2011 -|- lc g   0070.212000 a0.426000 002011"]) ))
      expect(page).to have_css(".panel-library-location a")
      expect(page).to have_css(".library-location-heading")
      expect(page).to have_css(".library-location-heading-text h3", text: "Earth Sciences Library (Branner)")
      expect(page).to have_css("div.location-hours-today")
      expect(page).to have_css(".panel-body")
    end
  end

  describe "bound with locations" do
    let(:document) do
      SolrDocument.new(
        id: '1234',
        item_display: ['1234 -|- SAL3 -|- SEE-OTHER -|- -|- -|- -|- -|- -|- ABC 123'],
        marcxml: linked_ckey_fixture
      )
    end

    before do
      render_inline(described_class.new(document: document))
    end

    it 'should display the MARC 590 as a bound with note (excluding subfield $c)' do
      expect(page).to have_css('.bound-with-note.note-highlight a', text: 'Copy 1 bound with v. 140')
      expect(page).not_to have_css('.bound-with-note.note-highlight', text: '55523 (parent record’s ckey)')
    end

    it "should not display request links for requestable libraries" do
      expect(page).not_to have_content("Request")
    end

    it 'should display the callnumber without live lookup' do
      expect(page).to have_css 'td', text: 'ABC 123'
      expect(page).not_to have_css 'td[data-live-lookup-id]'
    end
  end

  describe 'location level requests' do
    it 'should have the request link at the location level' do
      document = SolrDocument.new(
        id: '123',
        item_display: [
          '123 -|- GREEN -|- LOCKED-STK -|- -|- STKS-MONO -|- -|- -|- -|- ABC 123'
        ]
      )
      render_inline(described_class.new(document: document))
      expect(page).to have_css('.location a', text: "Request")
    end

    it 'should not have the location level request link for -RESV locations' do
      document = SolrDocument.new(
        id: '123',
        item_display: [
          '123 -|- SAL -|- SOMETHING-RESV -|- SOMETHING-RESV -|- -|- -|- -|- -|- ABC 123'
        ]
      )
      render_inline(described_class.new(document: document))
      expect(page).not_to have_css('a', text: "Request")
    end

    it 'should not have the location level request link for inprocess noncirculating collections' do
      document = SolrDocument.new(
        id: '123',
        item_display: [
          '123 -|- SPEC-COLL -|- GUNST -|- SPEC-INPRO -|- -|- -|- -|- -|- ABC 123'
        ]
      )
      render_inline(described_class.new(document: document))
      expect(page).not_to have_css('a', text: "Request")
    end
  end

  describe "status text" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display: [
          '123 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 123',
          '321 -|- SPEC-COLL -|- STACKS -|- -|- -|- -|- -|- -|- ABC 321'
        ]
      )
    end

    before do
      render_inline(described_class.new(document: document))
    end

    it "should have unknown status text for items we'll be looking up" do
      expect(page).to have_css('.status-text', text: 'Unknown')
    end
    it "should have explicit status text for items that we know the status" do
      expect(page).to have_css('.status-text', text: 'In-library use')
    end
  end

  describe "current locations" do
    it "should be displayed" do
      document = SolrDocument.new(
        id: '123',
        item_display: ['123 -|- GREEN -|- STACKS -|- INPROCESS -|- -|- -|- -|- -|- ABC 123']
      )
      render_inline(described_class.new(document: document))
      expect(page).to have_css('.current-location', text: 'In process')
    end
    describe "as home location" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- ART -|- STACKS -|- IC-DISPLAY -|- -|- -|- -|- -|- ABC 123']
        )
        render_inline(described_class.new(document: document))
      end

      it "should display the current location as the home location" do
        expect(page).not_to have_css('.location-name', text: 'Stacks')
        expect(page).to have_css('.location-name', text: 'Information Center display')
      end
      it "should not be displayed if the current location is a special location that gets treated like a home location" do
        expect(page).to have_css('.current-location', text: '')
      end
    end

    describe "is reserve desk" do
      it "should use the library of the owning reserve desk" do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- ART -|- STACKS -|- GREEN-RESV -|- -|- -|- -|- -|- ABC 123']
        )
        render_inline(described_class.new(document: document))
        expect(page).to have_css('.library-location-heading-text h3', text: 'Green Library')
      end
    end
  end

  describe "mhld" do
    describe "with matching library/location" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['321 -|- GREEN -|- STACKS -|- -|- STKS-MONO -|- -|- -|- -|- ABC 123'],
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        )
        render_inline(described_class.new(document: document))
      end

      it "should include the matched MHLD" do
        expect(page).to have_css('.panel-library-location a', count: 3)
        expect(page).to have_css('h3', text: "Green Library", count: 1)
        expect(page).to have_css('.location-name a', text: "Stacks", count: 1)
        expect(page).to have_css('.panel-library-location .mhld', text: "public note")
        expect(page).to have_css('.panel-library-location .mhld.note-highlight', text: "Latest: latest received")
        expect(page).to have_css('.panel-library-location .mhld', text: "Library has: library has")
        expect(page).to have_css('.panel-library-location td', text: "ABC 123")
      end
    end

    describe "that has no matching library/location" do
      before do
        document = SolrDocument.new(
          id: '123',
          mhld_display: ['GREEN -|- STACKS -|- public note -|- library has -|- latest received']
        )
        render_inline(described_class.new(document: document))
      end

      it "should invoke a library block w/ the appropriate mhld data" do
        expect(page).to have_css('.panel-library-location a', count: 1)
        expect(page).to have_css('h3', text: "Green Library")
        expect(page).to have_css('.location-name', text: "Stacks")
        expect(page).to have_css('.panel-library-location .mhld', text: "public note")
        expect(page).to have_css('.panel-library-location .mhld.note-highlight', text: "Latest: latest received")
        expect(page).to have_css('.panel-library-location .mhld', text: "Library has: library has")
      end
    end
  end

  describe "request links" do
    describe "location level request links" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- GREEN -|- LOCKED-STK -|- -|- STKS-MONO -|- -|- -|- -|- ABC 123']
        )
        render_inline(described_class.new(document: document))
      end

      it "should be present" do
        expect(page).to have_css('.location a', text: 'Request')
      end

      skip "should not have any requestable items" do
        expect(page).not_to have_css('td[data-request-url]')
      end
    end

    describe "item level request links" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- GREEN -|- STACKS -|- MISSING -|- -|- -|- -|- -|- ABC 123']
        )
        render_inline(described_class.new(document: document))
      end

      skip "should not have a request url stored in the data attribute" do
        expect(page).not_to have_css('td[data-request-url]')
      end

      it "should have a request link in the item" do
        expect(page).to have_css('tbody a', text: 'Request')
      end
    end

    describe "requestable vs. non-requestable items" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: [
            '123 -|- GREEN -|- STACKS -|- -|- NH-SOMETHING -|- -|- -|- -|- ABC 123',
            '456 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC 456'
          ]
        )
        render_inline(described_class.new(document: document))
      end

      pending "should have an item that has a request url" do
        expect(page).to have_css('.availability td[data-barcode="456"][data-request-url]')
      end

      skip "should have an item that does not have a request url" do
        expect(rendered).not_to have_css('.availability td[data-barcode="123"][data-request-url]')
      end
    end
  end

  describe "zombie libraries" do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display: [
          "123 -|- SUL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-",
          "456 -|- PHYSICS -|- PHYSTEMP -|- -|- -|- -|- -|- -|- DEF -|-",
          "789 -|- -|- ON-ORDER -|- ON-ORDER -|- -|- -|- -|- -|- GHI -|-"
        ]
      )
      render_inline(described_class.new(document: document))
    end

    it "should render a zombie library" do #mmm brains
      # This seems to be counting request links (not sure if that was the intent)
      expect(page).to have_css('.panel-library-location a', count: 1)
    end
    it "should render SUL items in the zombie library" do
      expect(page).to have_css('.panel-library-location td', text: 'ABC')
    end
    it "should render PHYSICS items in the zombie library" do
      expect(page).to have_css('.panel-library-location td', text: 'DEF')
    end
    it "should render blank (i.e. on order) items in the zombie library" do
      expect(page).to have_css('.panel-library-location td', text: 'GHI')
    end
  end

  describe 'public note' do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display: ['123 -|- SUL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|- -|- this is public']
      )
      render_inline(described_class.new(document: document))
    end

    it 'should render public note' do
      expect(page).to have_css('div.public-note.note-highlight', text: 'Note: this is public')
    end
  end

  describe 'finding aid' do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display: ['123 -|- SPEC-COLL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-'],
        url_suppl: ["http://oac.cdlib.org/findaid/ark:/something-else"]
      )
      render_inline(described_class.new(document: document))
    end

    it 'should display finding aid sections with link' do
      expect(page).to have_css('h4', text: 'Finding aid')
      expect(page).to have_css('a', text: 'Online Archive of California')
    end
  end

  describe 'special instructions' do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display: ['123 -|- SPEC-COLL -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-']
      )
      render_inline(described_class.new(document: document))
    end

    it 'should render special instructions field' do
      expect(page).to have_css('h4', text: 'On-site access')
      expect(page).to have_css('p', text: 'Researchers can request to view these materials in the Special Collections Reading Room. Request materials at least 2 business days in advance. Maximum 5 items per day.')
    end
  end

  describe 'Hoover Archives' do
    context 'when a finding aid is present' do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- HV-ARCHIVE -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-'],
          url_suppl: ['http://oac.cdlib.org/findaid/ark:/something-else']
        )
        render_inline(described_class.new(document: document))
      end

      it 'renders request via OAC finding aid' do
        expect(page).to have_css 'a[href*="oac"]', text: 'Request via Finding Aid'
        expect(page).to have_css '.availability-icon.noncirc_page'
        expect(page).to have_css '.status-text', text: 'In-library use'
      end
    end

    context 'without a finding aid' do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display: ['123 -|- HV-ARCHIVE -|- STACKS -|- -|- -|- -|- -|- -|- ABC -|-']
        )
        render_inline(described_class.new(document: document))
      end

      it 'renders not available text' do
        expect(page).to have_css '.panel-body .pull-right', text: 'Not available to request'
        expect(page).to have_css '.availability-icon.in_process'
        expect(page).to have_css '.status-text', text: 'In process'
      end
    end
  end
end
