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

  describe 'policy querying' do
    let(:rules) {
      [
        Folio::CirculationRules::Rule.new(
          { 'loan-type' => 'can-circ' },
          {
            'request' => 'allow-all',
            'loan' => '3day-norenew-15mingrace',
            'lost-item' => '30fee',
            'notice' => 'short',
            'overdue' => '150-1050'
          }
        ),
        Folio::CirculationRules::Rule.new(
          {},
          {
            'request' => 'no-requests',
            'loan' => '28day-norenew-1daygrace',
            'lost-item' => 'norepl',
            'notice' => 'default',
            'overdue' => 'nofine'
          }
        )
      ]
    }

    let(:policies) {
      {
        request: {
          'allow-all' => 'Allow all requests',
          'no-requests' => 'No requests allowed'
        },
        loan: {
          '3day-norenew-15mingrace' => '3 day loan, no renewals, 15 minute grace period',
          '28day-norenew-1daygrace' => '28 day loan, no renewals, 1 day grace period'
        },
        'lost-item': {
          'norepl' => 'No replacement',
          '30fee' => '$30 lost fee policy'
        },
        notice: {
          'short' => 'Short-term loan notice policy',
          'default' => 'Default notice policy'
        },
        overdue: {
          '150-1050' => '1.50/10.50 overdue fine',
          'nofine' => 'No fines policy'
        }
      }
    }

    let(:item) { instance_double(Holdings::Item) }

    subject(:service) { described_class.new(rules:, policies:) }

    before do
      allow(item).to receive(:material_type).and_return(Folio::Item::MaterialType.new(id: 'book', name: 'Books'))
      allow(item).to receive(:loan_type).and_return(Folio::Item::LoanType.new(id: 'can-circ', name: 'Can circulate'))
      allow(item).to receive(:effective_location).and_return(
        Folio::Location.new(
          campus: Folio::Location::Campus.new(id: 'sul', code: 'SUL', name: 'Stanford University Libraries'),
          library: Folio::Location::Library.new(id: 'green', code: 'GREEN', name: 'Cecil R. Green Library'),
          location: Folio::Location::Location.new(id: 'green-stacks', code: 'GRE-STACKS', name: 'Green Stacks')
        )
      )
    end

    it 'can fetch the request policy for an item' do
      expect(service.item_request_policy(item)).to eq('Allow all requests')
    end

    it 'can fetch the loan policy for an item' do
      expect(service.item_loan_policy(item)).to eq('3 day loan, no renewals, 15 minute grace period')
    end

    it 'can fetch the lost policy for an item' do
      expect(service.item_lost_policy(item)).to eq('$30 lost fee policy')
    end

    it 'can fetch the notice policy for an item' do
      expect(service.item_notice_policy(item)).to eq('Short-term loan notice policy')
    end

    it 'can fetch the overdue policy for an item' do
      expect(service.item_overdue_policy(item)).to eq('1.50/10.50 overdue fine')
    end
  end
end
