require 'rails_helper'

RSpec.describe 'Isbn' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: isbn_fixture) }

  let(:isbn_fixture) do
    <<-JSON
      {
        "leader": "          22        4500",
        "fields": [
          { "020": { "subfields": [ { "a": "0802142176" }, { "c": "$7.50" } ] } }
        ]
      }
    JSON
  end

  subject(:instance) { document.marc_field(:isbn) }

  it '#label' do
    expect(instance.label).to eq 'ISBN'
  end

  it '#values ignores subfield c' do
    expect(instance.values.length).to eq 1
    expect(instance.values).to include '0802142176'
  end

  context 'with only a $c' do
    let(:isbn_fixture) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            { "020": { "subfields": [ { "c": "$7.50" } ] } }
          ]
        }
      JSON
    end

    describe '#values' do
      it 'is empty' do
        expect(instance.values).to be_blank
      end
    end
  end
end
