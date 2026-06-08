# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IncludedWorks do
  include MarcMetadataFixtures

  subject(:instance) { described_class.new(document) }

  let(:document) { SolrDocument.new(marc_json_struct: contributed_works_fixture) }

  it 'handles included works with no $t punctuation' do
    expect(instance.values.first).to include(
      query_text: '710 with t ind2 Title! sub n after t',
      link_text: '710 with t ind2 Title! sub n after t',
      before_text: nil,
      after_text: nil
    )
  end

  it 'handles included works with punctuation after the $t' do
    expect(instance.values.last).to include(
      query_text: '711 with t ind2 Title! subu.',
      link_text: '711 with t ind2 middle Title! subu.',
      before_text: nil,
      after_text: 'sub n after .'
    )
  end

  it 'returns the right label' do
    expect(instance.label).to eq 'Included work'
  end
end
