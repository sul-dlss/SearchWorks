require 'spec_helper'

RSpec.describe Folio::CirculationRules::PolicyService do
  describe '#item_rule' do
    let(:rules) {
      [
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'loan-type' => '7day', 'location-campus' => 'sul' }, 'books-7day-sul'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'location-campus' => 'sul', 'location-library' => 'green' }, 'books-green'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book', 'loan-type' => 'reserves' }, 'books-reserves'),
        Folio::CirculationRules::Rule.new({ 'material-type' => { not: ['book'] }, 'loan-type' => 'reserves' }, 'other-reserves'),
        Folio::CirculationRules::Rule.new({ 'material-type' => 'book' }, 'books'),
        Folio::CirculationRules::Rule.new({ 'material-type' => { or: ['book', 'microform'] } }, 'book-or-microform'),
        Folio::CirculationRules::Rule.new({ 'location-library' => 'ars' }, 'ars'),
        Folio::CirculationRules::Rule.new({}, 'fallback')
      ]
    }

    let(:item) { instance_double(Holdings::Item) }

    subject(:service) { described_class.new(rules:) }

    context 'when no rules match the item' do
      before do
        allow(item).to receive(:material_type).and_return(Folio::Item::MaterialType.new(id: 'multimedia', name: 'Multimedia'))
        allow(item).to receive(:loan_type).and_return(Folio::Item::LoanType.new(id: '7hour', name: '7-hour reserve'))
        allow(item).to receive(:effective_location).and_return(
          Folio::Location.new(
            campus: Folio::Location::Campus.new(id: 'sul', code: 'SUL', name: 'Stanford University Libraries'),
            library: Folio::Location::Library.new(id: 'media-center', code: 'MEDIA-CENTER', name: 'Media & Microtext Center'),
            location: Folio::Location::Location.new(id: 'media-cage', code: 'MEDIA-CAGE', name: 'Media Cage')
          )
        )
      end

      it 'returns the fallback rule' do
        expect(service.item_rule(item).policy).to eq('fallback')
      end
    end

    context 'when a single rule matches the item' do
      before do
        allow(item).to receive(:material_type).and_return(Folio::Item::MaterialType.new(id: 'microform', name: 'Microform'))
        allow(item).to receive(:loan_type).and_return(Folio::Item::LoanType.new(id: '12hour', name: '12-hour reserve'))
        allow(item).to receive(:effective_location).and_return(
          Folio::Location.new(
            campus: Folio::Location::Campus.new(id: 'sul', code: 'SUL', name: 'Stanford University Libraries'),
            library: Folio::Location::Library.new(id: 'media-center', code: 'MEDIA-CENTER', name: 'Media & Microtext Center'),
            location: Folio::Location::Location.new(id: 'media-stacks', code: 'MEDIA-STACKS', name: 'Media Stacks')
          )
        )
      end

      it 'returns the matching rule' do
        expect(service.item_rule(item).policy).to eq('book-or-microform')
      end
    end

    context 'when multiple rules match the item' do
      before do
        allow(item).to receive(:material_type).and_return(Folio::Item::MaterialType.new(id: 'book', name: 'Books'))
        allow(item).to receive(:loan_type).and_return(Folio::Item::LoanType.new(id: '7day', name: '7-day loan'))
        allow(item).to receive(:effective_location).and_return(
          Folio::Location.new(
            campus: Folio::Location::Campus.new(id: 'sul', code: 'SUL', name: 'Stanford University Libraries'),
            library: Folio::Location::Library.new(id: 'green', code: 'GREEN', name: 'Cecil R. Green Library'),
            location: Folio::Location::Location.new(id: 'green-stacks', code: 'GRE-STACKS', name: 'Green Stacks')
          )
        )
      end

      it 'returns the highest priority matching rule' do
        expect(service.item_rule(item).policy).to eq('books-7day-sul')
      end
    end

    context 'when a rule applies to a library containing the item location' do
      before do
        allow(item).to receive(:material_type).and_return(Folio::Item::MaterialType.new(id: 'multimedia', name: 'Multimedia'))
        allow(item).to receive(:loan_type).and_return(Folio::Item::LoanType.new(id: 'rr', name: 'Reading room use only'))
        allow(item).to receive(:effective_location).and_return(
          Folio::Location.new(
            campus: Folio::Location::Campus.new(id: 'sul', code: 'SUL', name: 'Stanford University Libraries'),
            library: Folio::Location::Library.new(id: 'ars', code: 'ARS', name: 'Archive of Recorded Sound'),
            location: Folio::Location::Location.new(id: 'reference', code: 'REFERENCE', name: 'Reference')
          )
        )
      end

      it 'returns the matching rule' do
        expect(service.item_rule(item).policy).to eq('ars')
      end
    end
  end
end
