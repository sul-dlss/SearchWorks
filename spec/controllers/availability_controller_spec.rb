# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailabilityController do
  describe "bot traffic" do
    it "should return a forbidden status" do
      request.env['HTTP_USER_AGENT'] = 'robot'
      get :index, params: { ids: ['123'] }
      expect(response).to be_forbidden
    end
  end

  describe "without IDs" do
    it "should render a blank JSON array w/o making a live lookup request" do
      expect(LiveLookup).not_to receive(:new)
      get :index
      expect(response.body).to eq '[]'
    end
  end

  describe "with IDs" do
    let(:lookup) { double('new') }
    let(:json) { [{ a: 'a', b: 'b' }] }

    before do
      allow(lookup).to receive(:as_json).and_return(json)
    end

    it "should return the #to_json response from the LiveLookup class" do
      expect(LiveLookup).to receive(:new).with(['12345', '54321']).and_return(lookup)
      get :index, params: { ids: ['12345', '54321'] }
      expect(response.body).to eq json.to_json
    end
  end
end
