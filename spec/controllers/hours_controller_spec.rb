# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoursController do
  describe "routes" do
    it "routes to the library action with params" do
      expect(get: "/hours/GREEN").to route_to(controller: 'hours', action: 'show', id: 'GREEN')
    end
  end

  describe "GET library" do
    it "returns correct response" do
      get :show, params: { format: "json", id: "GREEN" }
      expect(response).to have_http_status :ok
    end
  end
end
