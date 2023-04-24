require 'rails_helper'

RSpec.describe Instrumentation do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: marc_382_instrumentation) }

  subject { described_class.new(document) }

  describe '#values' do
    it 'returns a Hash' do
      expect(subject.values.class).to eq Hash
    end

    it 'has two values grouped by instrumentation/partial instrumentation' do
      expect(subject.values.keys.length).to eq 2
      subject.values.each do |label, _| # rubocop:disable Style/HashEachMethods
        expect(label).to match(/(Instrumentation|Partial instrumentation)/)
      end
    end

    it 'grouped values should be an array' do
      subject.values.each do |_, values| # rubocop:disable Style/HashEachMethods
        expect(values.class).to eq Array
      end
    end

    it 'items in values array should have a label/value' do
      subject.values.each do |_, values| # rubocop:disable Style/HashEachMethods
        values.each do |item|
          expect(item).to have_key(:label)
          expect(item).to have_key(:value)
        end
      end
    end

    describe 'subfields' do
      it 'a subfield should equal the value' do
        expect(subject.values['Partial instrumentation'].first[:value]).to eq 'cowbell'
      end

      it 'b subfield should append "solo"' do
        expect(subject.values['Instrumentation'].first[:value]).to include 'solo flute (1)'
      end

      it 'd subfield should append a "/"' do
        expect(subject.values['Instrumentation'].first[:value]).to include ') / electronics ('
      end

      it 'n subfield should be appended to previous value and wrapped in parens' do
        expect(subject.values['Instrumentation'].first[:value]).to include 'singer (1)'
      end

      it 'p subfield should append "or"' do
        expect(subject.values['Instrumentation'].first[:value]).to include ') or bass guitar ('
      end

      it 's subfield should append "total=" and wrap in parens' do
        expect(subject.values['Instrumentation'].first[:value]).to include '(total=8)'
      end

      it 'v subfield should be wrapped in parens' do
        expect(subject.values['Instrumentation'].first[:value]).to include ') (4 hands),'
      end
    end
  end
end
