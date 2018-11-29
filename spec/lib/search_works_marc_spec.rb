require 'spec_helper'

describe SearchWorksMarc do
  include MarcMetadataFixtures

  describe 'initialize' do
    let(:document) { SolrDocument.new(marcxml: sw_marc_removed).to_marc }
    let(:sw_marc) { SearchWorksMarc.new(document) }

    it 'should be type SearchWorksMarc' do
      expect(sw_marc.class).to be SearchWorksMarc
    end
    it 'should not contain any control fields or removed custom fields' do
      expect(sw_marc.fields).to match_array []
    end
    it 'should contain these fields as the indicator value does not match' do
      document = SolrDocument.new(marcxml: sw_marc_not_removed).to_marc
      sw_marc = SearchWorksMarc.new(document)
      expect(sw_marc.fields.length).to eq 2
    end
  end

  describe 'parse_marc_record' do
    let(:document) { SolrDocument.new(marcxml: metadata1).to_marc }
    let(:sw_marc) { SearchWorksMarc.new(document) }

    it 'should return an array' do
      expect(sw_marc.parse_marc_record.class).to eq Array
    end
    it 'should have 16 values grouped by tag' do
      expect(sw_marc.parse_marc_record.count).to eq 16
      expect(sw_marc.parse_marc_record.map{ |f| f.label }.uniq.length).to eq 16
    end
    it 'grouped values should be an array' do
      sw_marc.parse_marc_record.each do |group|
        expect(group.values.class).to eq Array
      end
    end
    it 'items in array should be OpenStruct' do
      sw_marc.parse_marc_record.each do |group|
        expect(group.class).to eq OpenStruct
      end
    end
    it 'values should not contain excluded subfields' do
      expect(sw_marc.parse_marc_record.first.values.join('')).not_to match /\^A170662/
    end
    describe 'subfields' do
      it 'should equal the value' do
        expect(sw_marc.parse_marc_record[3].values.first).to match /Some intersting papers,/
      end
    end
  end

  describe 'each' do
    let(:document) { SolrDocument.new(marcxml: metadata1).to_marc }
    let(:instrumentation) { SearchWorksMarc.new(document) }

    it 'should return an enumerable object' do
      instrumentation.each do |record|
        expect(record).to be_a_kind_of(OpenStruct)
      end
    end
  end
end
