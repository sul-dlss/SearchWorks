require 'rails_helper'

RSpec.describe IncludedWorks do
  include MarcMetadataFixtures
  let(:document) { SolrDocument.new(marc_json_struct: contributed_works_fixture) }

  subject { described_class.new(document) }

  it 'handles included works with no $t punctuation' do
    expect(subject.values.first).to include(
      query_text: '710 with t ind2 Title! sub n after t',
      link_text: '710 with t ind2 Title! sub n after t',
      before_text: nil,
      after_text: nil
    )
  end

  it 'handles included works with punctuation after the $t' do
    expect(subject.values.last).to include(
      query_text: '711 with t ind2 Title! subu.',
      link_text: '711 with t ind2 middle Title! subu.',
      before_text: nil,
      after_text: 'sub n after .'
    )
  end

  it 'returns the right label' do
    expect(subject.label).to eq 'Included work'
  end
end
