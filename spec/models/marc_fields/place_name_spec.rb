# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Place names' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: fixture) }
  let(:fixture) { place_name_fixture }

  subject(:place_name) { document.marc_field(:hierarchical_place_name) }

  it 'returns MARC 752' do
    expect(place_name.values).to be_present
  end

  it 'is labeled Location' do
    expect(place_name.label).to eq 'Location'
  end

  it 'joins subfields with a --' do
    expect(place_name.values.length).to eq 1
    expect(place_name.values.first).to eq 'Florida -- Tampa'
  end

  context 'with a relator term ($e)' do
    let(:fixture) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            {
              "752": {
                "ind1": " ",
                "ind2": " ",
                "subfields": [
                  {
                    "a": "Scotland"
                  },
                  {
                    "d": "Edinburgh,"
                  },
                  {
                    "e": "publication place."
                  }
                ]
              }
            }
          ]
        }
      JSON
    end

    it 'appends the relator term to the previous field' do
      expect(place_name.values.first).to eq 'Scotland -- Edinburgh, publication place.'
    end
  end

  context 'with a relator term ($e) not preceded by the appropriate punctuation' do
    let(:fixture) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            {
              "752": {
                "ind1": " ",
                "ind2": " ",
                "subfields": [
                  {
                    "a": "England"
                  },
                  {
                    "d": "London"
                  },
                  {
                    "e": "publication place."
                  }
                ]
              }
            }
          ]
        }
      JSON
    end

    it 'adds a comma before the relator term' do
      expect(place_name.values.first).to eq 'England -- London, publication place.'
    end
  end
end
