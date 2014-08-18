require 'spec_helper'

describe Instrumentation do
  include MarcMetadataFixtures

  describe 'initialize' do
    let(:document) { SolrDocument.new(marcxml: marc_382_instrumentation).to_marc }
    let(:instrumentation) { Instrumentation.new(document) }
    it 'should be type Instrumentation' do
      expect(instrumentation.class).to eq Instrumentation
    end
    it "should contain only 382 fields" do
      instrumentation.marc_record.each do |record|
        expect(record.tag).to eq '382'
      end
    end
  end
  describe 'parse_marc_record' do
    let(:document) { SolrDocument.new(marcxml: marc_382_instrumentation).to_marc }
    let(:instrumentation) { Instrumentation.new(document) }
    it 'should return an array' do
      expect(instrumentation.parse_marc_record.class).to eq Array
    end
    it 'should have two values grouped by instrumentation/partial instrumentation' do
      expect(instrumentation.parse_marc_record.length).to eq 2
      instrumentation.parse_marc_record.each do |group|
        expect(group.label).to match /(Instrumentation|Partial instrumentation)/
      end
    end
    it "grouped values should be an array" do
      instrumentation.parse_marc_record.each do |group|
        expect(group.values.class).to eq Array
      end
    end
    it 'items in array should be OpenStruct' do
      instrumentation.parse_marc_record.each do |item|
        expect(item.class).to eq OpenStruct
      end
    end
    describe "subfields" do
      it 'a subfield should equal the value' do
        expect(instrumentation.parse_marc_record[1].values.first.first).to eq 'cowbell'
      end
      it 'n subfield should be appended to previous value' do
        expect(instrumentation.parse_marc_record[0].values.first.first).to eq 'singer (1)'
      end
      it 'd subfield should should add doubling' do
        expect(instrumentation.parse_marc_record[0].values.first[1]).to eq 'doubling bass guitar (2)'
      end
    end
  end
  describe 'each' do
    let(:document) { SolrDocument.new(marcxml: marc_382_instrumentation).to_marc }
    let(:instrumentation) { Instrumentation.new(document) }
    it 'should return an enumerable object' do
      instrumentation.each do |record|
        expect(record).to be_a_kind_of(OpenStruct)
      end
    end
  end
end
