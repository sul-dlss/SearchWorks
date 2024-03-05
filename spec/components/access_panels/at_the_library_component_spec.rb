require 'rails_helper'

RSpec.describe AccessPanels::AtTheLibraryComponent, type: :component do
  include MarcMetadataFixtures

  let(:non_present_library_doc) {
    SolrDocument.new(
      id: '123',
      item_display_struct: [
        { barcode: '36105217238315', library: 'SUL', effective_permanent_location_code: 'STACKS', type: 'STKS', lopped_callnumber: 'G70.212 .A426 2011', shelfkey: 'lc g   0070.212000 a0.426000 002011', reverse_shelfkey: 'en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~', callnumber: 'G70.212 .A426 2011',
          full_shelfkey: 'lc g   0070.212000 a0.426000 002011' }
      ]
    )
  }

  describe "#libraries" do
    let(:doc) {
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '36105217238315', library: 'EARTH-SCI', effective_permanent_location_code: 'STACKS', type: 'STKS', lopped_callnumber: 'G70.212 .A426 2011', shelfkey: 'lc g   0070.212000 a0.426000 002011', reverse_shelfkey: 'en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~', callnumber: 'G70.212 .A426 2011',
            full_shelfkey: 'lc g   0070.212000 a0.426000 002011' },
          { barcode: '36105217238315', library: 'SUL', effective_permanent_location_code: 'STACKS', type: 'STKS', lopped_callnumber: 'G70.212 .A426 2011', shelfkey: 'lc g   0070.212000 a0.426000 002011', reverse_shelfkey: 'en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~', callnumber: 'G70.212 .A426 2011',
            full_shelfkey: 'lc g   0070.212000 a0.426000 002011' }
        ]
      )
    }

    it "only returns the libraries" do
      expect(described_class.new(document: doc).libraries.length).to eq 2
    end
  end

  describe "render?" do
    it "has a library location present" do
      doc = SolrDocument.new(id: '123',
                             item_display_struct: [{ barcode: '36105217238315', library: 'EARTH-SCI', effective_permanent_location_code: 'STACKS', type: 'STKS',
                                                     lopped_callnumber: 'G70.212 .A426 2011', shelfkey: 'lc g   0070.212000 a0.426000 002011', reverse_shelfkey: 'en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~',
                                                     callnumber: 'G70.212 .A426 2011', full_shelfkey: 'lc g   0070.212000 a0.426000 002011' }])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "does not have a library location present" do
      doc = SolrDocument.new(id: '123')
      expect(described_class.new(document: doc).render?).to be false
    end
  end

  describe "object with a location" do
    it "renders the panel" do
      render_inline(described_class.new(document: SolrDocument.new(id: '123',
                                                                   item_display_struct: [{
                                                                     barcode: '36105217238315', library: 'EARTH-SCI', effective_permanent_location_code: 'STACKS', type: 'STKS',
                                                                     lopped_callnumber: 'G70.212 .A426 2011', shelfkey: 'lc g   0070.212000 a0.426000 002011', reverse_shelfkey: 'en~j~~~zzsz}xyxzzz~pz}vxtzzz~zzxzyy~~~~~~~~~~~~~~~',
                                                                     callnumber: 'G70.212 .A426 2011',
                                                                     full_shelfkey: 'lc g   0070.212000 a0.426000 002011'
                                                                   }]) ))
      expect(page).to have_css(".panel-library-location a")
      expect(page).to have_css(".library-location-heading")
      expect(page).to have_css(".library-location-heading-text h3", text: "Earth Sciences Library (Branner)")
      expect(page).to have_css("div.location-hours-today")
      expect(page).to have_css(".card-body")
    end
  end

  describe "bound with locations" do
    let(:document) do
      SolrDocument.new(
        id: '1234',
        item_display_struct: [
          { barcode: '1234', library: 'SAL3', effective_permanent_location_code: 'SAL3-STACKS', callnumber: 'ABC 123' }
        ],
        marc_json_struct: linked_ckey_fixture,
        holdings_json_struct: [
          { holdings: [
            {
              id: 'holding1234',
              location: {
                effectiveLocation: {
                  id: "158168a3-ede4-4cc1-8c98-61f4feeb22ea",
                  code: "SAL3-SEE-OTHER",
                  name: "See linked record to request items bound together",
                  campus: {
                    id: "c365047a-51f2-45ce-8601-e421ca3615c5",
                    code: "SUL",
                    name: "Stanford Libraries"
                  },
                  details: {},
                  library: {
                    id: "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                    code: "SAL3",
                    name: "SAL3 (off-campus storage)"
                  },
                  institution: {
                    id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    code: "SU",
                    name: "Stanford University"
                  }
                }
              },
              holdingsType: {
                id: "5b08b35d-aaa3-4806-998c-9cd85e5bc406",
                name: "Bound-with"
              },
              boundWith: {
                item: { barcode: "1234" },
                instance: { id: "7e194e58-e134-56fe-a3c2-2c0494e04c5b" }
              }
            }
          ] }
        ]
      )
    end

    before do
      render_inline(described_class.new(document:))
    end

    it 'has solr document eresources_library_display_name of nil' do
      expect(document.eresources_library_display_name).to be_nil
    end

    it 'displays the MARC 590 as a bound with note (excluding subfield $c)' do
      expect(page).to have_css('.bound-with-note.note-highlight a', text: 'Copy 1 bound with v. 140')
      expect(page).to have_no_css('.bound-with-note.note-highlight', text: '55523 (parent record’s ckey)')
    end

    it "does not display request links for requestable libraries" do
      expect(page).to have_no_content("Request")
    end

    it 'displays the callnumber with live lookup' do
      expect(page).to have_css 'td', text: 'ABC 123'
      expect(page).to have_css 'td[data-live-lookup-id]'
    end
  end

  describe 'location level requests' do
    let(:book_type) do
      Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
    end

    it 'should have the request link at the location level' do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'ART', effective_permanent_location_code: 'ART-LOCKED-LARGE', type: 'STKS-MONO', callnumber: 'ABC 123' }
        ]
      )

      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '123', barcode: '123',
                                     effective_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                     permanent_location: Folio::Types.cached_location_by_code('ART-LOCKED-LARGE'),
                                     location_provided_availability: nil,
                                     status: 'Available', material_type: book_type,
                                     loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])

      render_inline(described_class.new(document:))
      expect(page).to have_css('.location a', text: "Request")
    end

    it 'should not have the location level request link for inprocess noncirculating collections' do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'SPEC-COLL', effective_permanent_location_code: 'GUNST', temporary_location_code: 'SPEC-INPRO', callnumber: 'ABC 123' }
        ]
      )
      render_inline(described_class.new(document:))
      expect(page).to have_no_css('a', text: "Request")
    end
  end

  describe "status text" do
    let(:document) do
      SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 123' },
          { barcode: '321', library: 'SPEC-COLL', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 321' }
        ]
      )
    end
    let(:spec_location) do
      Folio::Types.cached_location_by_code('SPEC-STACKS')
    end

    before do
      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '321', barcode: '321',
                                     effective_location: spec_location,
                                     permanent_location: spec_location, status: 'Available',
                                     location_provided_availability: nil,
                                     material_type: instance_double(Folio::Item::MaterialType, id: nil),
                                     loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])
      render_inline(described_class.new(document:))
    end

    it "has unknown status text for items we'll be looking up" do
      expect(page).to have_css('.status-text', text: 'Unknown')
    end
    it "has explicit status text for items that we know the status" do
      expect(page).to have_css('.status-text', text: 'In-library use')
    end
  end

  describe "current locations" do
    let(:book_type) do
      Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
    end

    it "is displayed" do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', temporary_location_code: 'null', status: 'In process', effective_location: { details: { availabilityClass: 'In_process' } }, callnumber: 'ABC 123' }
        ]
      )

      allow(document).to receive(:folio_items).and_return([
        instance_double(Folio::Item, id: '123', barcode: '123', effective_location: Folio::Types.cached_location_by_code('GRE-STACKS'), permanent_location: Folio::Types.cached_location_by_code('GRE-STACKS'), status: 'In process', material_type: book_type, loan_type: instance_double(Folio::Item::LoanType, id: nil))
      ])

      render_inline(described_class.new(document:))
      expect(page).to have_css('.status-text', text: 'In process')
    end
  end

  describe "mhld" do
    context "with matching library/location" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', type: 'STKS-MONO', callnumber: 'ABC 123' }
          ],
          mhld_display: ['GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received']
        )
        render_inline(described_class.new(document:))
      end

      it "includes the matched MHLD" do
        expect(page).to have_css('.panel-library-location a', count: 3)
        expect(page).to have_css('h3', text: "Green Library", count: 1)
        expect(page).to have_css('.location-name a', text: "Stacks", count: 1)
        expect(page).to have_css('.panel-library-location .mhld', text: "public note")
        expect(page).to have_css('.panel-library-location .mhld.note-highlight', text: "Latest: latest received")
        expect(page).to have_css('.panel-library-location .mhld', text: "Library has: library has")
        expect(page).to have_css('.panel-library-location td', text: "ABC 123")
      end
    end

    context 'with multiple mhlds' do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'GRE-STACKS', type: 'STKS-MONO', callnumber: 'ABC 123' }
          ],
          mhld_display: [
            'GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received',
            'GREEN -|- GRE-STACKS -|- public note -|- library has2 -|- latest received'
          ]
        )
        render_inline(described_class.new(document:))
      end

      it "includes the latest received information only once" do
        expect(page).to have_css('.panel-library-location .mhld.note-highlight', text: "Latest: latest received", count: 1)
      end
    end

    context "with no matching library/location" do
      before do
        document = SolrDocument.new(
          id: '123',
          mhld_display: ['GREEN -|- GRE-STACKS -|- public note -|- library has -|- latest received']
        )
        render_inline(described_class.new(document:))
      end

      it "invokes a library block w/ the appropriate mhld data" do
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
      let(:document) do
        SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'ART', effective_permanent_location_code: 'ART-LOCKED-LARGE', type: 'STKS-MONO', callnumber: 'ABC 123' }
          ]
        )
      end

      let(:art_location) { Folio::Types.cached_location_by_code('ART-LOCKED-LARGE') }

      before do
        allow(document).to receive(:folio_items).and_return([
          instance_double(Folio::Item, id: '123', barcode: '123',
                                       effective_location: art_location,
                                       permanent_location: art_location, status: 'Available',
                                       location_provided_availability: nil,
                                       material_type: instance_double(Folio::Item::MaterialType, id: nil),
                                       loan_type: instance_double(Folio::Item::LoanType, id: nil))
        ])

        render_inline(described_class.new(document:))
      end

      it "should be present" do
        expect(page).to have_css('.location a', text: 'Request')
      end

      skip "should not have any requestable items" do
        expect(page).to have_no_css('td[data-request-url]')
      end
    end

    describe "item level request links" do
      let(:book_type) do
        Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
      end

      before do
        document = SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'STACKS', status: 'Missing', callnumber: 'ABC 123' }
          ]
        )
        allow(document).to receive(:folio_items).and_return([
          instance_double(Folio::Item, id: '123', barcode: '123',
                                       effective_location: Folio::Types.cached_location_by_code('GRE-STACKS'),
                                       permanent_location: Folio::Types.cached_location_by_code('GRE-STACKS'),
                                       location_provided_availability: nil,
                                       status: 'Missing', material_type: book_type,
                                       loan_type: instance_double(Folio::Item::LoanType, id: nil))
        ])
        render_inline(described_class.new(document:))
      end

      skip "should not have a request url stored in the data attribute" do
        expect(page).to have_no_css('td[data-request-url]')
      end

      it "should have a request link in the item" do
        expect(page).to have_css('tbody a', text: 'Request')
      end
    end

    describe "requestable vs. non-requestable items" do
      before do
        document = SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'GREEN', effective_permanent_location_code: 'STACKS', type: 'NH-SOMETHING', callnumber: 'ABC 123' },
            { barcode: '456', library: 'GREEN', effective_permanent_location_code: 'STACKS', callnumber: 'ABC 456' }
          ]
        )
        render_inline(described_class.new(document:))
      end

      pending "should have an item that has a request url" do
        expect(page).to have_css('.availability td[data-item-id="456"][data-request-url]')
      end

      skip "should have an item that does not have a request url" do
        expect(rendered).to have_no_css('.availability td[data-item-id="123"][data-request-url]')
      end
    end
  end

  describe "zombie libraries" do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '789', status: 'On order', callnumber: 'GHI 789' }
        ]
      )
      render_inline(described_class.new(document:))
    end

    it "renders a zombie library" do #mmm brains
      # This seems to be counting request links (not sure if that was the intent)
      expect(page).to have_css('.panel-library-location a', count: 1)
    end
    it "renders blank (i.e. on order) items in the zombie library" do
      expect(page).to have_css('.panel-library-location td', text: 'GHI')
    end
  end

  describe 'public note' do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'SUL', effective_permanent_location_code: 'STACKS', callnumber: 'ABC', note: 'this is public' }
        ]
      )
      render_inline(described_class.new(document:))
    end

    it 'renders public note' do
      expect(page).to have_css('div.public-note.note-highlight', text: 'Note: this is public')
    end
  end

  describe 'finding aid' do
    before do
      document = SolrDocument.new(
        id: '123',
        item_display_struct: [
          { barcode: '123', library: 'SPEC-COLL', effective_permanent_location_code: 'STACKS', callnumber: 'ABC' }
        ],
        marc_links_struct: [{ href: "http://oac.cdlib.org/findaid/ark:/something-else", finding_aid: true }]
      )
      render_inline(described_class.new(document:))
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
        item_display_struct: [
          { barcode: '123', library: 'SPEC-COLL', effective_permanent_location_code: 'STACKS', callnumber: 'ABC' }
        ]
      )
      render_inline(described_class.new(document:))
    end

    it 'renders special instructions field' do
      expect(page).to have_css('h4', text: 'On-site access')
      expect(page).to have_css('p', text: 'Collections are moving, which may affect access. Request materials as early as possible. Maximum 5 items per day. Contact specialcollections@stanford.edu for information about access.')
    end
  end

  describe 'Hoover Archives' do
    context 'when a finding aid is present' do
      let(:book_type) do
        Folio::Item::MaterialType.new(**Folio::Types.material_types.values.find { |x| x['name'] == 'book' }.slice('id', 'name'))
      end

      before do
        document = SolrDocument.new(
          id: '123',
          item_display_struct: [
            { barcode: '123', library: 'HILA', effective_permanent_location_code: 'STACKS', callnumber: 'ABC' }
          ],
          marc_links_struct: [{ href: "http://oac.cdlib.org/findaid/ark:/something-else", finding_aid: true }]
        )
        allow(document).to receive(:folio_items).and_return([
          instance_double(Folio::Item, id: '123', barcode: '123',
                                       effective_location: Folio::Types.cached_location_by_code('HILA-STACKS'),
                                       permanent_location: Folio::Types.cached_location_by_code('HILA-STACKS'),
                                       location_provided_availability: nil,
                                       status: 'Available', material_type: book_type,
                                       loan_type: instance_double(Folio::Item::LoanType, id: nil))
        ])
        render_inline(described_class.new(document:))
      end

      it 'renders request via OAC finding aid' do
        expect(page).to have_css 'a[href*="oac"]', text: 'Request via Finding Aid'
        expect(page).to have_css '.availability-icon.noncirc'
        expect(page).to have_css '.status-text', text: 'In-library use'
      end
    end
  end
end
