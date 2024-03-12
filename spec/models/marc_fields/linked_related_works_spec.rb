# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinkedRelatedWorks do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: linked_related_works_fixture) }

  subject(:instance) { described_class.new(document) }

  it '#label' do
    expect(instance.label).to eq 'Related Work'
  end

  context '#values' do
    let(:data) { instance.values.first }

    it '#pre_text' do
      expect(data[:pre_text]).to include 'i1_subfield_text: i2_subfield_text:' # in order
    end

    it '#link' do
      %w[a d f k l h m n o p r s t].each do |code|
        expect(data[:link]).to include "#{code}_subfield_text"
      end
      %w[i1 i2 x1 x2].each do |code|
        expect(data[:link]).not_to include "#{code}_subfield_text"
      end
    end

    it '#search' do
      %w[a d f k l m n o p r s t].each do |code|
        expect(data[:search]).to include "#{code}_subfield_text"
      end
    end

    it '#post_text' do
      text = 'x1_subfield_text. x2_subfield_text. 3_subfield_text' # in order
      expect(data[:post_text]).to include text
      %w[0 5 8].each do |code| # always excluded
        expect(data[:post_text]).not_to include "#{code}_subfield_text"
      end
    end
  end
end
