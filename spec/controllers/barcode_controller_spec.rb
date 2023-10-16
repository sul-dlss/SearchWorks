# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BarcodeController do
  describe 'routes' do
    it 'is available at /barcode' do
      request = { get: '/barcode/3610512345' }
      expect(request).to route_to(controller: 'barcode', action: 'show', id: '3610512345')
    end
  end

  describe 'GET show' do
    it 'renders the json returned by the BarcodeSearch class' do
      json = { id: 'abc123', barcode: '3610512345' }
      expect(BarcodeSearch).to receive(:new).with('3610512345').and_return(json)

      get :show, params: { id: '3610512345' }

      expect(response).to be_successful
      response_json = response.parsed_body
      expect(response_json['id']).to eq(json[:id])
      expect(response_json['barcode']).to eq(json[:barcode])
    end
  end
end
