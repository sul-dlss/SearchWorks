# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::EdsCitation do
  let(:eds_citations) do
    [
      { 'id' => 'apa', 'data' => 'Citation Content' },
      { 'status' => 'error', 'description' => 'Could not do a thing' },
      { 'id' => 'somestyle', 'data' => 'Citation that should not display' },
      { 'id' => 'mla' },
      { 'data' => 'Citation that should not display' }
    ]
  end

  subject(:eds_citation) { described_class.new(eds_citations:) }

  describe '#all_citations' do
    it 'returns a hash with the available citations' do
      expect(eds_citation.all_citations).to eq('apa' => 'Citation Content')
    end
  end
end
