# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoursController do
  describe "routes" do
    it "should route to the library action with params" do
      expect(get: "/hours/GREEN").to route_to(controller: 'hours', action: 'show', id: 'GREEN')
    end
  end

  describe "GET library" do
    it "should return correct response" do
      get :show, params: { format: "json", id: "GREEN" }
      expect(response.status).to eq 200
    end
  end
end
