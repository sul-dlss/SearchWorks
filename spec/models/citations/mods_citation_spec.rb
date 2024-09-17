# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citations::ModsCitation do
  include ModsFixtures

  let(:note) { SolrDocument.new(modsxml: mods_preferred_citation).mods.note }

  subject(:mods_citation) { described_class.new(notes: note) }

  describe '#all_citations' do
    it 'returns a hash with the preferred citation' do
      expect(mods_citation.all_citations).to eq({ 'preferred' => '<p>This is the preferred citation data</p>' })
    end
  end
end
