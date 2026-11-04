# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PhysicalMedium' do
  include MarcMetadataFixtures

  subject(:instance) { document.marc_field(340) }

  let(:document) { SolrDocument.new(marc_json_struct: physical_medium_fixture) }

  it '#label' do
    expect(instance.label).to eq 'Medium'
  end

  it '#values has correct delimiters' do
    expect(instance.values.length).to eq 1
    expect(instance.values).to include 'a; c; d1; d2; m'
  end
end
