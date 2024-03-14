# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MarcInstrumentation' do
  include MarcMetadataFixtures
  it 'should return nil for non marc object' do
    document = SolrDocument.new
    expect(document.marc_instrumentation).to be_nil
  end

  it 'should return empty marc_record for marc doc without 382 field' do
    document = SolrDocument.new(marc_json_struct: metadata1)
    expect(document.marc_instrumentation.values.length).to eq 0
  end

  it 'should return Instrumentation for document with 382 field' do
    document = SolrDocument.new(marc_json_struct: marc_382_instrumentation)
    expect(document.marc_instrumentation.class).to eq Instrumentation
  end
end
