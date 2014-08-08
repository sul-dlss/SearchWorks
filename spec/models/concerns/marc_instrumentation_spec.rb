require 'spec_helper'

describe MarcInstrumentation do
  include MarcMetadataFixtures
  it 'should return nil for non marc object' do
    document = SolrDocument.new()
    expect(document.marc_instrumentation).to be nil
  end
  it 'should return empty marc_record for marc doc without 382 field' do
    document = SolrDocument.new(marcxml: metadata1)
    expect(document.marc_instrumentation.marc_record.length).to eq 0
  end
  it 'should return SearchWorksMarc::Instrumentation for document with 382 field' do
    document = SolrDocument.new(marcxml: marc_382_instrumentation)
    expect(document.marc_instrumentation.class).to eq SearchWorksMarc::Instrumentation
  end
end
