require 'spec_helper'

class MarcInstrumentationTestClass
  include MarcInstrumentation
end

describe MarcInstrumentation do
  include MarcMetadataFixtures
  it 'should return nil for non marc records' do
    expect(MarcInstrumentationTestClass.new.marc_instrumentation).to be_nil
  end

  describe 'marc382 text format' do
    let(:inst) { SolrDocument.new(marcxml: marc_382_instrumentation) }
    let(:part) { SolrDocument.new(marcxml: marc_382_partial_instrumentation) }
    it 'should contain a dt for Instrumentation' do
      expect(inst.marc_instrumentation.text).to match /(<dt>Instrumentation<\/dt>){1}/
    end
    it 'should not contain two dts for Instrumentation' do
      expect(inst.marc_instrumentation.text).to_not match /(<dt>Instrumentation<\/dt>){2}/
    end
    it 'should contain 2 dds for Instrumentation' do
      expect(inst.marc_instrumentation.text).to match /(<dd>.*<\/dd>){2}/
    end
    it 'should contain 1 dt for Partial instrumentation' do
      expect(part.marc_instrumentation.text).to match /(<dt>Partial instrumentation<\/dt>){1}/
    end
    it 'should contain 1 dd for Partial instrumentation' do
      expect(inst.marc_instrumentation.text).to match /(<dd>.*<\/dd>){1}/
    end
  end
end
