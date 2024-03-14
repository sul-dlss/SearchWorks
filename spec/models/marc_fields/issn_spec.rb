# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Issn' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: issn_fixture) }

  subject(:instance) { document.marc_field(:issn) }

  it '#label' do
    expect(instance.label).to eq 'ISSN'
  end

  it '#values has valid ISSNs' do
    expect(instance.values.length).to eq 3
    expect(instance.values).to include '0041-4034', '1234-1230', '5678-567X any old text'
  end
end
