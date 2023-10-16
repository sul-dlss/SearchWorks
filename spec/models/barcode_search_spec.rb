# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BarcodeSearch do
  subject { described_class.new(barcode) }

  let(:barcode) { '3610512345' }
  let(:stub_response) do
    { response: { docs: [{ id: 'abc123' }] } }.with_indifferent_access
  end
  let(:stub_no_docs_response) do
    { response: { docs: [] } }.with_indifferent_access
  end

  describe 'when the barcode search returns a document' do
    before do
      expect(subject).to receive_messages(response: stub_response)
    end

    it 'gets the document id from the first document in the response' do
      expect(subject.document_id).to eq('abc123')
    end

    it 'has a json response that returns the barcode and id' do
      expect(subject.as_json[:barcode]).to eq '3610512345'
      expect(subject.as_json[:id]).to eq 'abc123'
    end
  end

  describe 'when the barcode search does not return a document' do
    before do
      expect(subject).to receive_messages(response: stub_no_docs_response)
    end

    it 'returns nil for the document_id' do
      expect(subject.document_id).to be_nil
    end
  end
end
