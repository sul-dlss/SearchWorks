# frozen_string_literal: true

FactoryBot.define do
  factory :holdings_json_struct, class: 'Array' do
    transient do
      location factory: :gre_stacks
      # rubocop:disable FactoryBot/FactoryAssociationWithStrategy https://github.com/rubocop/rubocop-factory_bot/issues/73
      item { build(:item, :available, location:) }
      # rubocop:enable FactoryBot/FactoryAssociationWithStrategy
    end

    initialize_with {
      [
        {
          'holdings' => [
            {
              'id' => '11',
              'location' => location
            }
          ],
          'items' => [
            item
          ]
        }
      ]
    }
  end
end
