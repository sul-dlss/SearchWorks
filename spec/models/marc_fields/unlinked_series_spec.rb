require 'rails_helper'

RSpec.describe UnlinkedSeries do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: complex_series_fixture) }

  subject { described_class.new(document) }

  describe '#label' do
    it 'is Series' do
      expect(subject.label).to eq 'Series'
    end
  end

  describe '#values' do
    it 'returns an item in the array for every unlinked series' do
      expect(subject.values.length).to eq 2
    end

    it 'returns only alpha subfields' do
      expect(subject.values.first).to eq 'Non-linkable 490'
    end

    it 'does not link 490s if the indicator1 is not 0' do
      expect(subject.values.first).to eq 'Non-linkable 490'
    end

    it 'does not link series if they have multiple $a' do
      expect(subject.values.last).to include 'Non-linkable 800'
    end
  end
end
