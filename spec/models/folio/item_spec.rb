# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folio::Item do
  let(:json) {
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
      'permanentLoanTypeId' => '2b94c631-fca9-4892-a730-03ee529ffe27'
    }
  }

  describe '#loan_type' do
    context 'when there is a temporary loan type' do
      before do
        json['temporaryLoanType'] = 'Course reserves'
        json['temporaryLoanTypeId'] = 'e8b311a6-3b21-43f2-a269-dd9310cb2d0e'
      end

      subject { described_class.from_dynamic(json).loan_type }

      it 'returns the temporary loan type' do
        expect(subject.name).to eq 'Course reserves'
      end
    end

    context 'when there is not a temporary loan type' do
      subject { described_class.from_dynamic(json).loan_type }

      it 'returns the permanent loan type' do
        expect(subject.name).to eq 'Can circulate'
      end
    end
  end
end
