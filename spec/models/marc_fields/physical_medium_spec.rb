require 'spec_helper'

describe PhysicalMedium do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marcxml: physical_medium_fixture) }

  subject(:instance) { described_class.new(document) }

  it '#label' do
    expect(instance.label).to eq 'Medium'
  end

  it '#values has correct delimiters' do
    expect(instance.values.length).to eq 1
    expect(instance.values).to include 'a; c; d1; d2; m'
  end
end
