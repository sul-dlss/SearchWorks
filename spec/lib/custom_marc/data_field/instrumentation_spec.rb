require 'spec_helper'

describe CustomMarc::Subfield::Instrumentation do

  describe 'indicator' do
    let(:instrumentation) { CustomMarc::DataField::Instrumentation.new(indicator: '0') }
    let(:partial_instrumentation) { CustomMarc::DataField::Instrumentation.new(indicator: '1') }
    it 'should return instrumentation' do
      expect(instrumentation.indicator).to eq 'Instrumentation'
    end
    it 'should return partial instrumentation' do
      expect(partial_instrumentation.indicator).to eq 'Partial instrumentation'
    end
  end

  describe 'append_to_previous' do
    let(:instrumentation) { CustomMarc::DataField::Instrumentation.new(indicator: '0') }
    it 'should return values appended to eachother' do
      expect(instrumentation.append_to_previous('s',[1, 2], 0)).to eq '1 s'
    end
  end

  describe 'subfields_to_text' do
    let(:instrumentation) {
      CustomMarc::DataField::Instrumentation.new(
        indicator: '0',
        subfields: [
          OpenStruct.new(code: 'a', value: 'piano'),
          OpenStruct.new(code: 'n', value: '2'),
          OpenStruct.new(code: 'd', value: 'bass guitar'),
          OpenStruct.new(code: 'n', value: '4'),
          OpenStruct.new(code: 'e', value: 'stuff'),
          OpenStruct.new(code: 'b', value: 'trombone'),
          OpenStruct.new(code: 'l', value: 'fake instrument')
        ]
      )
    }
    it 'should return correctly formatted array of text' do
      expect(instrumentation.subfields_to_text).to eq ["piano (2)", "doubling bass guitar (4)", "solo trombone"]
    end
  end
end
