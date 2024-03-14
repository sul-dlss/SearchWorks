# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DOIs' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: doi_fixture) }

  subject(:instance) { document.marc_field(:doi) }

  it '#label' do
    expect(instance.label).to eq 'DOI'
  end

  it '#values has fields with the DOI' do
    expect(instance.values.length).to eq 1
    expect(instance.values).to include '10.1111/j.1600-0447.1938.tb03723.x'
  end

  context 'with other 024 data' do
    let(:doi_fixture) { other_024_fixture }

    it 'has no values' do
      expect(instance.values).to be_empty
    end
  end
end
