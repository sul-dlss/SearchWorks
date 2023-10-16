require 'rails_helper'

RSpec.describe LinkedCollection do
  include MarcMetadataFixtures
  let(:document) do
    SolrDocument.new(
      { collection_struct: [{ 'title' => 'Shao shu min zu she hui li shi diao cha',
                              'vernacular' => '少数民族社会历史调查',
                              'source' => 'sirsi' }] }
    )
  end

  subject { described_class.new(document) }

  describe '#label' do
    it 'is Collection' do
      expect(subject.label).to eq 'Collection'
    end
  end

  describe '#values' do
    it 'returns values for each linkable field' do
      expect(subject.values.length).to eq 2
    end

    it 'returns the collection titles' do
      expect(subject.values.first).to eq 'Shao shu min zu she hui li shi diao cha'
      expect(subject.values.last).to eq '少数民族社会历史调查'
    end
  end

  describe '#to_partial_path' do
    it 'is overriden from the base partial path' do
      expect(subject.to_partial_path).to eq 'marc_fields/linked_collection'
    end
  end
end
