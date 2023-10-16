require 'rails_helper'

RSpec.describe OrganizationAndArrangement do
  include MarcMetadataFixtures
  subject { described_class.new(SolrDocument.new(marc_json_struct: organization_and_arrangement_fixture)) }

  describe 'label' do
    it 'is "Organization & arrangement"' do
      expect(subject.label).to eq 'Organization & arrangement'
    end
  end

  describe 'values' do
    it 'selects $3, $a, $b, and $c for display' do
      expect(subject.values.length).to eq 1
      expect(subject.values.first).to eq '351 $3 351 $c 351 $a 351 $b'
    end
  end
end
