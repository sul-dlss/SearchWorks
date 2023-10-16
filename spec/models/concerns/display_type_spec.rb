require 'rails_helper'

RSpec.describe DisplayType do
  let(:document_attributes) { {} }

  subject { SolrDocument.new(document_attributes).display_type }

  describe 'MARC' do
    let(:document_attributes) do
      { marc_json_struct: '{}' }
    end

    it 'returns "marc"' do
      expect(subject).to eq 'marc'
    end

    context 'when a collection' do
      let(:document_attributes) do
        { collection_type: ['Digital Collection'], marc_json_struct: '{}' }
      end

      it 'returns "marc_collection"' do
        expect(subject).to eq 'marc_collection'
      end
    end
  end

  describe 'MODS' do
    let(:document_attributes) do
      { modsxml: '<xml />' }
    end

    it 'returns "mods"' do
      expect(subject).to eq 'mods'
    end

    context 'when a collection' do
      let(:document_attributes) do
        { collection_type: ['Digital Collection'], modsxml: '<xml />' }
      end

      it 'returns "mods_collection"' do
        expect(subject).to eq 'mods_collection'
      end
    end
  end

  describe 'unknown documents' do
    it 'returns marc when there is not enough information to determine display type' do
      expect(subject).to eq 'marc'
    end
  end
end
