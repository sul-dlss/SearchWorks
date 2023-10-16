require 'rails_helper'

RSpec.describe Imprint do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: edition_imprint_fixture) }

  subject { described_class.new(document) }

  it 'returns MARC 260' do
    expect(subject.values).to be_present
  end

  it 'joins subfields w/ a space' do
    expect(subject.values.length).to eq 1
    expect(subject.values.first).to eq 'SubA SubB SubC SubG'
  end

  it 'does not include subfields that should not be displayed' do
    expect(subject.values.length).to eq 1
    expect(subject.values.first).not_to match(/SubZ/)
  end

  it 'is labeled Imprint' do
    expect(subject.label).to eq 'Imprint'
  end
end
