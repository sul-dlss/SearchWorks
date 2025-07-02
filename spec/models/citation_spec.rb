# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citation do
  include ModsFixtures
  let(:document) { SolrDocument.new }
  let(:mods_citation) { instance_double(Citations::ModsCitation, all_citations: { 'preferred' => 'Mods citation content' }) }

  subject { described_class.new(document) }

  context 'when there is a MODS citation' do
    let(:document) { SolrDocument.new(modsxml: mods_preferred_citation) }

    before do
      allow(Citations::ModsCitation).to receive(:new).and_return(mods_citation)
    end

    it { expect(subject).to be_citable }

    it 'returns the MODS citations' do
      expect(subject.citations).to eq({ 'preferred' => 'Mods citation content' })
    end
  end
end
