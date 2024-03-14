# frozen_string_literal: true

require 'rails_helper'

def marc_fields(marc, field)
  SolrDocument.new(marc_json_struct: marc).to_marc.fields(field)
end

RSpec.describe MarcFieldWrapper do
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

    describe 'when the $6 points to a non-880' do
      let(:field) { marc_fields(bad_vernacular_fixture, '610').first }

      it { expect(subject).not_to be_vernacular_matcher }
    end

    describe 'when the $6 in an 880 does not point to a regular marc field' do
      let(:field) do
        marc_fields(bad_vernacular_fixture, '880').find { |f| f['6'] == '880-00'  }
      end

      it { expect(subject).not_to be_vernacular_matcher }
    end
  end

  describe '#==' do
    let(:field) { marc_fields(metadata1, '100').first }
    let(:other_field) { marc_fields(complex_vernacular_fixture, '880').first }

    it 'is true for the same object' do
      expect(subject).to eq subject
    end

    it 'is true if the object wraps the same field' do
      expect(subject).to eq described_class.new(field)
    end

    it 'is false if the object wraps different fields' do
      expect(subject).not_to eq described_class.new(other_field)
    end

    it 'is false if they are totally different objects' do
      expect(subject).not_to eq ''
    end
  end
end
