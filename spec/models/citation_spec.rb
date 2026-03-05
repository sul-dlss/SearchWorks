# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citation do
  include ModsFixtures

  subject { described_class.new(document) }

  context 'when there is a MODS citation' do
    let(:document) { SolrDocument.new(modsxml: mods_preferred_citation) }

    it { expect(subject).to be_citable }

    it 'returns the MODS citations' do
      expect(subject.citations).to eq({ 'preferred' => 'This is the preferred citation data' })
    end
  end

  context 'when there is a COCINA citation' do
    let(:document) { SolrDocument.new(cocina_struct: cocina_preferred_citation) }
    let(:cocina_preferred_citation) do
      [
        { "description" => {
          'note' => [{ 'type' => 'preferred citation', 'value' => 'This is the preferred citation data' }]
        } }.to_json
      ]
    end

    it { expect(subject).to be_citable }

    it 'returns the citation' do
      expect(subject.citations).to eq({ 'preferred' => 'This is the preferred citation data' })
    end
  end
end
