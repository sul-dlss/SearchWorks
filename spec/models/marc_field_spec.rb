require 'spec_helper'

describe MarcField do
  include MarcMetadataFixtures
  let(:marc) { metadata1 }
  let(:document) { SolrDocument.new(marcxml: marc) }
  let(:tags) { [] }
  subject { described_class.new(document, tags) }

  describe '#label' do
    it 'falls back to a default label' do
      expect(subject.label).to eq 'Field'
    end
  end

  describe '#values' do
    let(:tags) { %w(600) }

    it 'returns an array of concatenated subfields' do
      expect(subject.values.length).to eq 3
      expect(subject.values).to include 'Arbitrary, Stewart.'
    end

    context 'matching vernacular values' do
      let(:tags) { %w(245 505) }
      let(:marc) { matched_vernacular_fixture }

      it 'are interfiled in the metadata' do
        expect(subject.values.length).to eq 4
        expect(subject.values[0]).to eq 'This is not Vernacular'
        expect(subject.values[1]).to eq 'This is Vernacular'
        expect(subject.values[2]).to eq '1.This is not Vernacular -- 2.This is also not Vernacular'
        expect(subject.values[3]).to eq '1.This is Vernacular -- 2.This is also Vernacular'
      end
    end

    context 'unmatched vernacular fields' do
      let(:tags) { %w(245 505) }
      let(:marc) { unmatched_vernacular_fixture }

      it 'returns fields for the requested tags even when there is no data present' do
        expect(subject.values.length).to eq 2
      end
    end

    context 'complex vernacular matching' do
      let(:tags) { %w(245 300 350) }
      let(:marc) { complex_vernacular_fixture }

      it 'interfiles the matched and unmatched vernacular properly' do
        expect(subject.values.length).to eq 8
        expect(subject.values[0]).to eq '245 Matched Romanized'
        expect(subject.values[1]).to eq '245 Matched Vernacular'
        expect(subject.values[2]).to eq '300 Unmatched Romanized'
        expect(subject.values[3]).to eq '300 Matched Romanized'
        expect(subject.values[4]).to eq '300 Matched Vernacular'
        expect(subject.values[5]).to eq '300 Unmatched Vernacular'
        expect(subject.values[6]).to eq '350 Matched Romanized'
        expect(subject.values[7]).to eq '350 Matched Vernacular'
      end
    end
  end

  describe '#to_partial_path' do
    it 'has a fallback partial path' do
      expect(subject.to_partial_path).to eq 'marc_fields/marc_field'
    end
  end

  describe 'preprocessors' do
    let(:tags) { %w(600) }

    context 'fields that should not be displayed' do
      let(:marc) { metadata2 }
      let(:tags) { %w(541 760) }

      it 'are not present' do
        expect(subject.values).to be_blank
      end
    end

    context 'subfields that should not be displayed' do
      it 'are not present' do
        subject.values.each do |value|
          expect(value).not_to include 'UNAUTHORIZED'
          expect(value).not_to include 'A170662'
        end
      end
    end
  end
end
