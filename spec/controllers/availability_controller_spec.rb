require "spec_helper"

describe AvailabilityController do
  before do
    Settings.FOLIO_LIVE_LOOKUP = false
  end

  describe "bot traffic" do
    it "should return a forbidden status" do
      request.env['HTTP_USER_AGENT'] = 'robot'
      get :index, params: { ids: ['123'] }
      expect(response).to be_forbidden
    end
  end

  describe "without IDs" do
    it "should render a blank JSON array w/o making a live lookup request" do
      expect(SirsiLiveLookup).not_to receive(:new)
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

    it "should return the #to_json response from the SirsiLiveLookup class" do
      expect(SirsiLiveLookup).to receive(:new).with(['12345', '54321']).and_return(lookup)
      get :index, params: { ids: ['12345', '54321'] }
      expect(response.body).to eq json.to_json
    end

    it 'should not make a lookup request to FOLIO' do
      expect(FolioLiveLookup).not_to receive(:new)
      get :index, params: { ids: ['12345', '54321'] }
    end
  end

  context 'when FOLIO_LIVE_LOOKUP is true' do
    let(:lookup) { double('new') }
    let(:json) { [{ a: 'a', b: 'b' }] }

    before do
      Settings.FOLIO_LIVE_LOOKUP = true
      allow(lookup).to receive(:as_json).and_return(json)
    end

    it 'should make the lookup request to FOLIO instead of Sirsi' do
      expect(SirsiLiveLookup).not_to receive(:new)
      expect(FolioLiveLookup).to receive(:new).with(['12345', '54321']).and_return(lookup)
      get :index, params: { ids: ['12345', '54321'] }
    end
  end
end
