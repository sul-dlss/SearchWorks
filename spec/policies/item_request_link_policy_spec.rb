require 'spec_helper'

RSpec.describe ItemRequestLinkPolicy do
  subject(:policy) { described_class.new(item:) }

  describe '#show?' do
    subject { policy.show? }

    context 'when folio_item exists' do
      let(:item) { instance_double(Holdings::Item, folio_item?: true, on_reserve?: false, effective_location:, material_type:, loan_type:) }

      let(:effective_location) do
        Folio::Location.from_dynamic(
          {
            'id' => '1146c4fa-5798-40e1-9b8e-92ee4c9f2ee2',
            'code' => 'SAL3-STACKS',
            'name' => 'SAL3 Stacks',
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
              'id' => 'ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9',
              'code' => 'SAL3',
              'name' => 'Stanford Auxiliary Library 3'
            }
          }
        )
      end
      let(:material_type) { Folio::Item::MaterialType.new(id: '1a54b431-2e4f-452d-9cae-9cee66c9a892', name: 'book') }
      let(:loan_type) { Folio::Item::LoanType.new(id: '2b94c631-fca9-4892-a730-03ee529ffe27', name: 'Can circulate') }

      context 'when the item is requestable' do
        it { is_expected.to be true }
      end

      context 'when the item is on reserve' do
        let(:item) { instance_double(Holdings::Item, folio_item?: true, on_reserve?: true, effective_location:) }

        it { is_expected.to be false }
      end

      context 'when the item is aeon pageable' do
        let(:effective_location) do
          Folio::Location.from_dynamic(
            {
              'id' => '1f3a8d48-2de3-432d-923e-76eb93de9ffc',
              'code' => 'SPEC-SAL3-RBC',
              'name' => 'SAL3 Rare books',
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
                'id' => 'ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9',
                'code' => 'SAL3',
                'name' => 'Stanford Auxiliary Library 3'
              }
            }
          )
        end

        it { is_expected.to be false }
      end

      context 'when the item is mediated pageable' do
        let(:effective_location) do
          Folio::Location.from_dynamic(
            {
              'id' => 'd3bf7d1b-53ce-4075-9d5e-7bd2f27e014e',
              'code' => 'ART-LOCKED-OVERSIZE',
              'name' => 'Art Locked Stacks Oversize',
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
                'id' => 'ddd3bce1-9f8f-4448-8d6d-b6c1b3907ba9',
                'code' => 'SAL3',
                'name' => 'Stanford Auxiliary Library 3'
              }
            }
          )
        end

        it { is_expected.to be false }
      end
    end
  end
end
