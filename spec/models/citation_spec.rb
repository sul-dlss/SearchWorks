# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citation do
  let(:document) { SolrDocument.new(cocina_struct: cocina_preferred_citation) }
  let(:cocina_preferred_citation) do
    [
      { "description" => {
        'note' => [{ 'type' => 'preferred citation', 'value' => 'This is the preferred citation data' }]
      } }.to_json
    ]
  end

  subject { described_class.new(document) }

  it { expect(subject).to be_citable }

  it 'returns the citation' do
    expect(subject.citations).to eq({ 'preferred' => 'This is the preferred citation data' })
  end
end
