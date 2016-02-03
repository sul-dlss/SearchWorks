require 'spec_helper'

describe BoundWithNote do
  include MarcMetadataFixtures
  let(:marc) { linked_ckey_fixture }
  let(:document) { SolrDocument.new(marcxml: marc) }
  subject { described_class.new(document, %w(590)) }

  describe '#values' do
    it 'returns an array of hashes that include a value and an ID' do
      expect(subject.values.length).to eq 1
      expect(subject.values.first[:id]).to eq '55523'
      expect(subject.values.first[:value]).to include 'Copy 1 bound with v. 140 55523 (parent record’s ckey)'
    end
  end

  describe '#to_partial_path' do
    it 'provides a custom partial path' do
      expect(subject.to_partial_path).to eq 'marc_fields/bound_with_note'
    end
  end

  describe 'preprocessors' do
    it 'removes any fields that do not include a $c' do
      expect(subject.values.length).to eq 1
      expect(subject.values.first[:value]).to_not match(/A 590 that does not have \$c/)
    end
  end
end
