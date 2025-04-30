# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citation do
  include ModsFixtures
  let(:document) { SolrDocument.new }
  let(:mods_citation) { instance_double(Citations::ModsCitation, all_citations: { 'preferred' => 'Mods citation content' }) }
  let(:oclc_citation) do
    instance_double(Citations::OclcCitation, citations_by_oclc_number: { '12345' => { 'harvard' => 'OCLC citation content' } })
  end
  let(:oclc_enabled) { true }

  subject { described_class.new(document) }

  before do
    allow(Settings.oclc_discovery.citations).to receive(:enabled).and_return(oclc_enabled)
  end

  context 'when OCLC is not configured and there are no other citations' do
    let(:oclc_enabled) { false }
    let(:document) { SolrDocument.new(oclc: '12345') }

    it { expect(subject).not_to be_citable }

    it 'returns the null citation' do
      expect(subject.citations).to eq({ 'NULL' => '<p>No citation available for this record</p>' })
    end
  end

  context 'when there is an OCLC number' do
    let(:document) { SolrDocument.new(oclc: '12345') }

    before do
      allow(Citations::OclcCitation).to receive(:new).and_return(oclc_citation)
    end

    it { expect(subject).to be_citable }

    it 'returns the OCLC citations' do
      expect(subject.citations).to eq({ 'harvard' => 'OCLC citation content' })
    end
  end

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
