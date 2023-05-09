require 'spec_helper'

RSpec.describe Folio::CirculationRules::PolicyService do
  describe '#item_rule' do
    let(:rules) {
      [
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'loan-type' => '7-day reserve', 'location-campus' => 'SUL' }, 'books-7day-sul'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'location-campus' => 'SUL', 'location-library' => 'GREEN' }, 'books-green'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'loan-type' => 'reserves' }, 'books-reserves'),
        Folio::CirculationRules::Rule.new({ 'material-type' => { not: ['book'] }, 'loan-type' => 'reserves' }, 'other-reserves'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book' }, 'books'),
        Folio::CirculationRules::Rule.new({ 'material-type' => { or: ['book', 'microform'] } }, 'book-or-microform'),
        Folio::CirculationRules::Rule.new({ 'location-library' => 'ARS' }, 'ars'),
        Folio::CirculationRules::Rule.new({}, 'fallback')
      ]
    }

    subject(:service) { described_class.new(rules:) }

    context 'when no rules match the item' do
      let(:item) {
        {
          'material-type' => 'multimedia',
          'loan-type' => '7-hour reserve',
          'location-institution' => 'SU',
          'location-campus' => 'SUL',
          'location-library' => 'MEDIA-CENTER',
          'location-location' => 'MEDIA-CAGE'
        }
      }

      it 'returns the fallback rule' do
        expect(service.item_rule(item).policy).to eq('fallback')
      end
    end

    context 'when a single rule matches the item' do
      let(:item) {
        {
          'material-type' => 'microform',
          'loan-type' => '12 hour',
          'location-institution' => 'SU',
          'location-campus' => 'SUL',
          'location-library' => 'MEDIA-CENTER',
          'location-location' => 'MEDIA-STACKS'
        }
      }

      it 'returns the matching rule' do
        expect(service.item_rule(item).policy).to eq('book-or-microform')
      end
    end

    context 'when multiple rules match the item' do
      let(:item) {
        {
          'material-type' => 'book',
          'loan-type' => '7-day reserve',
          'location-institution' => 'SU',
          'location-campus' => 'SUL',
          'location-library' => 'GREEN',
          'location-location' => 'STACKS'
        }
      }

      it 'returns the highest priority matching rule' do
        expect(service.item_rule(item).policy).to eq('books-7day-sul')
      end
    end

    context 'when a rule applies to a library containing the item location' do
      let(:item) {
        {
          'material-type' => 'multimedia',
          'loan-type' => 'Reading room',
          'location-institution' => 'SU',
          'location-campus' => 'SUL',
          'location-library' => 'ARS',
          'location-location' => 'REFERENCE'
        }
      }

      it 'returns the matching rule' do
        expect(service.item_rule(item).policy).to eq('ars')
      end
    end
  end
end
