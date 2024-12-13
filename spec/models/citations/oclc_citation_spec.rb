# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::OclcCitation do
  let(:oclc_numbers) { '123456' }
  let(:oclc_citation) { described_class.new(oclc_numbers:) }
  let(:oclc_client) { instance_double(OclcDiscoveryClient) }
  let(:oclc_enabled) { true }

  before do
    allow(OclcDiscoveryClient).to receive(:new).and_return(oclc_client)
    allow(oclc_client).to receive(:citations).and_return(
      ['entries' => [{ 'oclcNumber' => '12345', 'style' => 'apa', 'citationText' => 'Citation Content' },
                     { 'oclcNumber' => '12345', 'resultType' => 'problem', 'type' => 'UNSUPPORTED_MATERIAL_FORMAT_TYPE' }]]
    )
    allow(Settings.oclc_discovery.citations).to receive(:enabled).and_return(oclc_enabled)
  end

  describe '#citations_by_oclc_number' do
    it 'returns a hash with the available citations' do
      expect(oclc_citation.citations_by_oclc_number).to(
        eq({ '12345' => { 'apa' => 'Citation Content' } })
      )
    end
  end

  context 'when OCLC is not configured' do
    let(:oclc_enabled) { false }

    it 'returns an empty hash' do
      expect(oclc_citation.citations_by_oclc_number).to eq({})
    end
  end
end
