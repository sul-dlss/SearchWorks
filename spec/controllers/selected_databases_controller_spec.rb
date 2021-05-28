require 'spec_helper'

describe SelectedDatabasesController do
  describe "#index" do
    it "should set the @selected_databases instance variable" do
      docs = double('documents')

      expect(controller).to receive(:fetch).and_return([double('response'), docs])
      get :index
      expect(assigns(:selected_databases)).to eq docs
    end
  end

  describe "routes" do
    describe "/selected_databases" do
      it "should route to the index action" do
        expect({ get: "/selected_databases" }).to route_to(controller: 'selected_databases', action: 'index')
      end
    end
  end
end
