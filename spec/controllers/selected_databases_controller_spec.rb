# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelectedDatabasesController do
  describe "#index" do
    it "sets the @selected_databases instance variable" do
      docs = double('documents')

      allow(controller).to receive(:search_service).and_return(double('MockSearchService', fetch: docs))
      get :index
      expect(assigns(:selected_databases)).to eq docs
    end
  end

  describe "routes" do
    describe "/selected_databases" do
      it "routes to the index action" do
        expect({ get: "/selected_databases" }).to route_to(controller: 'selected_databases', action: 'index')
      end
    end
  end
end
