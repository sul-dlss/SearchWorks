require 'spec_helper'

describe CatalogController do
  it "should include the DatabaseAccessPoint concern" do
    expect(subject).to be_kind_of(DatabaseAccessPoint)
  end
  describe "#index" do
    it "should set the search modifier" do
      get :index
      expect(assigns(:search_modifier)).to be_a SearchQueryModifier
    end
  end
  describe "routes" do
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
end
