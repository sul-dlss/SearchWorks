# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folio::Item do
  let(:book_json) {
    {
      'id' => '64d4220b-ebae-5fb0-971c-0f98f6d9cc93',
      'status' => 'Available',
      'barcode' => '36105232609557',
      'location' => {
        'effectiveLocation' => {
          'id' => '4573e824-9273-4f13-972f-cff7bf504217',
          'code' => 'GRE-STACKS',
          'name' => 'Green Library Stacks',
          'campus' => {
            'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
            'code' => 'SUL',
            'name' => 'Stanford Libraries'
          },
          'library' => {
            'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
            'code' => 'GREEN',
            'name' => 'Cecil H. Green'
          },
          'institution' => {
            'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
            'code' => 'SU',
            'name' => 'Stanford University'
          }
        },
        'permanentLocation' => {
          'id' => '4573e824-9273-4f13-972f-cff7bf504217',
          'code' => 'GRE-STACKS',
          'name' => 'Green Library Stacks',
          'campus' => {
            'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
            'code' => 'SUL',
            'name' => 'Stanford Libraries'
          },
          'library' => {
            'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
            'code' => 'GREEN',
            'name' => 'Cecil H. Green'
          },
          'institution' => {
            'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
            'code' => 'SU',
            'name' => 'Stanford University'
          }
        },
        'temporaryLocation' => nil
      },
      'materialType' => 'book',
      'materialTypeId' => '1a54b431-2e4f-452d-9cae-9cee66c9a892',
      'permanentLoanType' => 'Can circulate',
      'temporaryLoanType' => nil,
      'temporaryLoanTypeId' => nil,
      'permanentLoanTypeId' => '2b94c631-fca9-4892-a730-03ee529ffe27',
      "callNumber" => {
        "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
        "typeName" => "Library of Congress classification",
        "callNumber" => "PN1995.9.M6 A76 2024"
      }
    }
  }

  subject(:instance) { described_class.from_dynamic(json) }

  describe '#loan_type' do
    let(:json) { book_json }

    subject { instance.loan_type }

    context 'when there is a temporary loan type' do
      before do
        json['temporaryLoanType'] = 'Course reserves'
        json['temporaryLoanTypeId'] = 'e8b311a6-3b21-43f2-a269-dd9310cb2d0e'
      end

      it 'returns the temporary loan type' do
        expect(subject.name).to eq 'Course reserves'
      end
    end

    context 'when there is not a temporary loan type' do
      it 'returns the permanent loan type' do
        expect(subject.name).to eq 'Can circulate'
      end
    end
  end

  describe '#constructed_call_number' do
    subject { instance.constructed_call_number }

    context 'with a book' do
      let(:json) { book_json }

      it { is_expected.to eq 'PN1995.9.M6 A76 2024' }
    end

    context 'with a serial' do
      let(:json) do
        {
          "id" => "3ea88693-29b8-5e22-bb60-5cca36deb465",
          "status" => "Available",
          "barcode" => "36105235737025",
          "callNumber" => {
            "typeId" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
            "typeName" => "Library of Congress classification",
            "callNumber" => "G155 .S38 S464c f"
          },
          "enumeration" => "2022/2024",
          "materialType" => "periodical",
          "callNumberType" => {
            "id" => "95467209-6d7b-468b-94df-0f5d7ad2747d",
            "name" => "Library of Congress classification",
            "source" => "system"
          },
          "materialTypeId" => "d934e614-215d-4667-b231-aed97887f289",
          'permanentLoanType' => 'Can circulate',
          'temporaryLoanType' => nil,
          'temporaryLoanTypeId' => nil,
          'permanentLoanTypeId' => '2b94c631-fca9-4892-a730-03ee529ffe27',
          "location" => {
            "effectiveLocation" => {
              "id" => "1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2",
              "code" => "SAL3-STACKS",
              "name" => "Stacks",
              "campus" => {
                "id" => "c365047a-51f2-45ce-8601-e421ca3615c5",
                "code" => "SUL",
                "name" => "Stanford Libraries"
              },
              "details" => {
                "availabilityClass" => "Offsite",
                "scanServicePointCode" => "SAL3"
              },
              "library" => {
                "id" => "ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9",
                "code" => "SAL3",
                "name" => "SAL3 (off-campus storage)"
              },
              "institution" => {
                "id" => "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                "code" => "SU",
                "name" => "Stanford University"
              }
            }
          }
        }
      end

      it { is_expected.to eq 'G155 .S38 S464c f 2022/2024' }
    end
  end
end
