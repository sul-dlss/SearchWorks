require 'rails_helper'

RSpec.describe LinkedSeries do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: complex_series_fixture) }

  subject { described_class.new(document) }

  describe '#label' do
    it 'is Series' do
      expect(subject.label).to eq 'Series'
    end
  end

  describe '#values' do
    it 'returns values for each linkable field' do
      expect(subject.values.length).to eq 3
    end

    context '490 local series field' do
      it 'returns only the $a in the link' do
        expect(subject.values[1][:link]).to match(/Linkable 490/)
      end

      it 'appends the rest of the alpha subfields at the end of the link' do
        expect(subject.values[1][:extra_text]).to match(/490 \$b/)
        expect(subject.values[1][:extra_text]).not_to match(/\$4 should not display/)
      end
    end

    context 'other series fields' do
      it 'returns all alpha (except $v and $x) in the link' do
        expect(subject.values[0][:link]).to match(/440 \$a/)
        expect(subject.values[2][:link]).to match(/Name SubZ/)
      end

      it 'appends $v and $x to the end of the link' do
        expect(subject.values[0][:extra_text]).to match(/440 \$v 440 \$x/)
        expect(subject.values[2][:extra_text]).to match(/SubV800/)
      end
    end
  end

  describe '#to_partial_path' do
    it 'is overriden from the base partial path' do
      expect(subject.to_partial_path).to eq 'marc_fields/linked_series'
    end
  end
end
