require 'spec_helper'

def marc_fields(marc, field)
  SolrDocument.new(marcxml: marc).to_marc.fields(field)
end

describe MarcFieldWrapper do
  include MarcMetadataFixtures
  subject { described_class.new(field) }

  describe '#canonical_tag' do
    context 'for regular fields' do
      let(:field) { marc_fields(complex_vernacular_fixture, '245').first }

      it 'returns the fields original tag' do
        expect(subject.canonical_tag).to eq '245'
      end
    end

    context 'for vernacualr fields' do
      let(:field) { marc_fields(complex_vernacular_fixture, '880').first }

      it 'returns the tag of the field it matches' do
        expect(subject.canonical_tag).to eq '245'
      end
    end
  end

  describe '#vernacular_matcher_tag' do
    let(:field) { marc_fields(complex_vernacular_fixture, '880').first }

    it 'returns the tag of the field it matches' do
      expect(subject.vernacular_matcher_tag).to eq '245'
    end
  end

  describe '#vernacular_matcher_iterator' do
    let(:field) { marc_fields(complex_vernacular_fixture, '880').first }

    it 'returns the iterator associated with that parituclar vernacular matching field' do
      expect(subject.vernacular_matcher_iterator).to eq '01'
    end
  end

  describe '#vernacular_matcher?' do
    context 'when $6 is present' do
      let(:field) { marc_fields(complex_vernacular_fixture, '880').first }

      it 'is true' do
        expect(subject).to be_vernacular_matcher
      end
    end

    context 'when $6 is not present' do
      let(:field) { marc_fields(metadata1, '100').first }

      it 'is false' do
        expect(subject).not_to be_vernacular_matcher
      end
    end
  end
end
