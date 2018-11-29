# frozen_string_literal: true

require 'spec_helper'

describe PlaceName do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marcxml: place_name_fixture) }

  subject(:place_name) { described_class.new(document) }

  it 'returns MARC 752' do
    expect(place_name.values).to be_present
  end

  it 'is labeled Location' do
    expect(place_name.label).to eq 'Location'
  end

  it 'joins subfields with a --' do
    expect(place_name.values.length).to eq 1
    expect(place_name.values.first).to eq 'Florida -- Tampa'
  end
end
