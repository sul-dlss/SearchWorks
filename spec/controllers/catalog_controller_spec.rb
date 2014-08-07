require 'spec_helper'

describe CatalogController do
  it "should include the DatabaseAccessPoint concern" do
    expect(subject).to be_kind_of(DatabaseAccessPoint)
  end
  it "should include the CallnumberSearch concern" do
    expect(subject).to be_kind_of(CallnumberSearch)
  end
  it "should include the AllCapsParams concern" do
    expect(subject).to be_kind_of(AllCapsParams)
  end
  it "should include the ReplaceSpecialQuotes concern" do
    expect(subject).to be_kind_of(ReplaceSpecialQuotes)
  end
  it "should include CJKQuery" do
    expect(subject).to be_kind_of(CJKQuery)
  end
  describe "#index" do
    it "should set the search modifier" do
      get :index
      expect(assigns(:search_modifier)).to be_a SearchQueryModifier
    end
  end
  describe "routes" do
    describe "customized from Blacklight" do
      it "should route /view/:id properly" do
        expect({get: '/view/1234'}).to route_to(controller: 'catalog', action: 'show', id: '1234')
      end
      it "should route catalog_path to /view" do
        expect(catalog_path('1234')).to eq '/view/1234'
      end
      it "should route solr_document_path to /view" do
        expect(solr_document_path('1234')).to eq '/view/1234'
      end
      it "should route the librarian view properly" do
        expect({get: '/view/1234/librarian_view' }).to route_to(controller: 'catalog', action: 'librarian_view', id: '1234')
      end
      it "should route the stackmap view properly" do
        expect({get: '/view/1234/stackmap' }).to route_to(controller: 'catalog', action: 'stackmap', id: '1234')
      end
    end
    describe "/databases" do
      it "should route to the database format" do
        expect({get: "/databases"}).to route_to(controller: 'catalog', action: 'index', f: { "format" => ["Database"] })
      end
    end
    describe "/backend_lookup" do
      it "should route to the backend lookup path as json" do
        expect({get: "/backend_lookup"}).to route_to(controller: 'catalog', action: 'backend_lookup', format: :json)
      end
    end
  end
  describe "blacklight config" do
    let(:config) { controller.blacklight_config }
    it "should have the correct facet order" do
      keys = config.facet_fields.keys
      expect(keys.index("access_facet")).to be < keys.index("format_main_ssim")
      expect(keys.index("format_main_ssim")).to be < keys.index("format_physical_ssim")
      expect(keys.index("format_physical_ssim")).to be < keys.index("pub_year_tisim")
      expect(keys.index("pub_year_tisim")).to be < keys.index("building_facet")
      expect(keys.index("building_facet")).to be < keys.index("language")
      expect(keys.index("language")).to be < keys.index("author_person_facet")
      expect(keys.index("author_person_facet")).to be < keys.index("topic_facet")
      expect(keys.index("topic_facet")).to be < keys.index("genre_ssim")
      expect(keys.index("genre_ssim")).to be < keys.index("callnum_top_facet")
      expect(keys.index("callnum_top_facet")).to be < keys.index("geographic_facet")
      expect(keys.index("geographic_facet")).to be < keys.index("era_facet")
      expect(keys.index("era_facet")).to be < keys.index("author_other_facet")
      expect(keys.index("author_other_facet")).to be < keys.index("format")
    end
    describe "facet limits" do
      it "should set a very high facet limit on building and format" do
        ['building_facet', 'format_main_ssim'].each do |facet|
          expect(config.facet_fields[facet].limit).to eq 100
        end
      end
      it "should set the correct facet limits on standard facets" do
        ['author_person_facet', 'topic_facet', 'genre_ssim'].each do |facet|
          expect(config.facet_fields[facet].limit).to eq 20
        end
      end
    end
  end
end
