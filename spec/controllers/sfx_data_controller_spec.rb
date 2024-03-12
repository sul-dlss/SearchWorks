# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SfxDataController do
  describe 'setting up SfxData' do
    it 'unescapes the incoming URL param' do
      expect(SfxData).to receive(:new).with('http://example.com').and_return(double(targets: []))

      get :show, params: { url: Addressable::URI.encode('http://example.com') }
    end
  end

  context 'when the SfxData has targets' do
    before do
      expect(SfxData).to receive(:new).and_return(double(targets: ['something']))
    end

    it 'is successful and renders the show template' do
      get :show, params: { url: Addressable::URI.encode('http://example.com') }

      expect(response).to be_successful
      expect(response).to render_template('show')
    end
  end

  context 'when a URL does not have SFX data' do
    it 'returns a 404/Not Found' do
      get :show, params: { url: Addressable::URI.encode('http://example.com') }

      expect(response).to be_not_found
    end
  end
end
