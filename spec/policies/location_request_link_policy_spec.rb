# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationRequestLinkPolicy do
  subject(:policy) { described_class.new(location:, library_code:) }

  let(:library_code) { 'HILA' }
  let(:location) { instance_double(Holdings::Location, code: 'STACKS', items:) }

  describe '#show?' do
    subject { policy.show? }

    context 'when there is a bound-with in folio' do
      # Seen in a404313 for HOOVER/STACKS where it says "Scattered issues missing"
      let(:items) { [instance_double(Holdings::Item, document:, folio_item?: false)] }
      let(:document) {
        SolrDocument.new(holdings_json_struct: [{ 'holdings' => [
          {
            'id' => '123456', 'holdingsType' => { 'code' => 'Bound-with' },
            'location' => {
              'effectiveLocation' => {
                'id' => "158168a3-ede4-4cc1-8c98-61f4feeb22ea",
                'code' => "SAL3-SEE-OTHER",
                'name' => "Off-campus storage",
                'campus' => { id: "c365047a-51f2-45ce-8601-e421ca3615c5", code: "SUL", name: "Stanford Libraries" },
                "details" => nil,
                "library" => { id: "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9", code: "SAL3", name: "Stanford Auxiliary Library 3" },
                "isActive" => true,
                "institution" => { id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929", code: "SU", name: "Stanford University" }
              }
            }
          }
        ] }])
      }

      it { is_expected.to be false }
    end

    context 'when there is a SPEC-COLL in-process location in folio' do
      let(:library_code) { 'SPEC-COLL' }
      let(:items) { [instance_double(Holdings::Item, folio_item?: true, folio_status: 'In process (non-requestable)', effective_location:)] }
      let(:effective_location) do
        Folio::Location.from_dynamic(
          {
            "id" => "2065af65-904d-41bb-8db8-35bff753cf64",
            "name" => "Spec Inprocess RWC",
            "code" => "SPEC-INPROCESS-RWC",
            'institution' => {
              'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
              'code' => 'SU',
              'name' => 'Stanford University'
            },
            'campus' => {
              'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
              'code' => 'SUL',
              'name' => 'Stanford Libraries'
            },
            'library' => {
              'id' => '5b61a365-6b39-408c-947d-f8861a7ba8ae',
              'code' => 'SPEC-COLL',
              'name' => 'Special Collections'
            }
          }
        )
      end

      it { is_expected.to be false }
    end
  end
end
