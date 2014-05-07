require 'spec_helper'

describe CatalogController do
  describe "routes" do
    describe "/databases" do
      it "should route to the database format" do
        expect({get: "/databases"}).to route_to(controller: 'catalog', action: 'index', f: { "format" => ["Database"] })
      end
    end
  end
end
