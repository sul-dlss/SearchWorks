# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedController do
  let(:embed) { double('embed') }

  describe "routes" do
    it "should route to the show action with ID passed in" do
      expect(get: "/embed/abc123").to route_to(controller: 'embed', action: 'show', id: 'abc123')
    end
  end

  describe "GET show" do
    before do
      expect(PURLEmbed).to receive(:new).with('abc123').and_return(embed)
      expect(embed).to receive(:html).and_return("<p>stuff</p>")
    end

    it "should return correct response" do
      get :show, params: { format: "json", id: "abc123" }
      expect(response).to have_http_status :ok
    end
  end
end
