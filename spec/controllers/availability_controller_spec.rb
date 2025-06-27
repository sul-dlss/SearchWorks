# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailabilityController do
  describe "bot traffic" do
    it "returns a forbidden status" do
      request.env['HTTP_USER_AGENT'] = 'robot'
      get :index, params: { ids: ['123'] }
      expect(response).to be_forbidden
    end
  end

  describe "without IDs" do
    it "renders a blank JSON array w/o making a live lookup request" do
      expect(LiveLookup).not_to receive(:new)
      get :index
      expect(response.body).to eq '[]'
    end
  end

  describe "with a blank ID" do
    it "renders a blank JSON array w/o making a live lookup request" do
      expect(LiveLookup).not_to receive(:new)
      get :index, params: { ids: [''] }
      expect(response.body).to eq '[]'
    end
  end

  describe "with IDs" do
    let(:lookup) { double('new') }
    let(:json) { [{ a: 'a', b: 'b' }] }

    before do
      allow(lookup).to receive(:as_json).and_return(json)
    end

    it "returns the #to_json response from the LiveLookup class" do
      expect(LiveLookup).to receive(:new).with(['12345', '54321']).and_return(lookup)
      get :index, params: { ids: ['12345', '54321'] }
      expect(response.body).to eq json.to_json
    end
  end

  describe '#show' do
    it 'looks up the document and RTAC' do
      document = SolrDocument.from_fixture("1391872.yml")
      allow(controller).to receive(:search_service).and_return(double(fetch: document))
      allow(LiveLookup).to receive(:new).with('b0e0445b-dc19-5e05-a85c-5ecbad784255').and_return(double(records: [{ item_id: '217453b4-0585-517f-859c-bab10d948554' }]))

      get :show, params: { id: '1391872' }

      expect(assigns(:document)).to eq(document)
      expect(assigns(:rtac)).to eq({ '217453b4-0585-517f-859c-bab10d948554' => { item_id: '217453b4-0585-517f-859c-bab10d948554' } })
    end
  end
end
