# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subjects' do
  include MarcMetadataFixtures

  let(:document) { SolrDocument.new(marc_json_struct: marc) }

  subject(:subjects) { document.subjects('650') }

  context 'with subjects in the $a' do
    let(:marc) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            { "650": { "ind1": "1", "ind2": " ", "subfields": [ { "a": "Barley" }, { "a": "Malt" } ] } }
          ]
        }
      JSON
    end

    it 'turns each $a into a separate value' do
      expect(subjects.values).to eq [['Barley'], ['Malt']]
    end
  end

  context 'with nomesh subjects' do
    let(:marc) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            { "650": { "ind1": "1", "ind2": " ", "subfields": [ { "a": "nomesh" } ] } }
          ]
        }
      JSON
    end

    it 'suppresses the subjects' do
      expect(subjects.values).to be_empty
    end
  end

  context 'with nomeshx subjects' do
    let(:marc) do
      <<-JSON
        {
          "leader": "          22        4500",
          "fields": [
            { "650": { "ind1": "1", "ind2": " ", "subfields": [ { "a": "nomeshx" } ] } }
          ]
        }
      JSON
    end

    it 'suppresses the subjects' do
      expect(subjects.values).to be_empty
    end
  end
end
