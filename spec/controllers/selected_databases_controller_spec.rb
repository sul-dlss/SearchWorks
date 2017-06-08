require 'spec_helper'

describe SelectedDatabasesController do
  describe "#index" do
    it "should set the @selected_databases instance variable" do
      expect(controller).to receive(:fetch).and_return([double('response'), double('documents')])
      get :index
      expect(assigns(:selected_databases)).to be_a SelectedDatabases
    end
  end
  describe "routes" do
    describe "/selected_databases" do
      it "should route to the index action" do
        expect({get: "/selected_databases"}).to route_to(controller: 'selected_databases', action: 'index')
      end
    end
  end
end
