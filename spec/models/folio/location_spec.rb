# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folio::Location do
  let(:json) {
    {
      'id' => '1af90de1-a5c0-4c46-bab1-2847d041f997',
      'code' => 'GRE-BENDER',
      'name' => 'Green Bender Room',
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
        'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
        'code' => 'GREEN',
        'name' => 'Cecil H. Green'
      }
    }
  }

  describe '#new' do
    context 'with no institution' do
      subject { described_class.new(id: 'uuid', code: 'baz', campus: 'foo', library: 'bar') }

      it 'uses the default institution' do
        expect(subject.institution.name).to eq 'Stanford University'
      end
    end
  end

  describe '#from_dynamic' do
    subject { described_class.from_dynamic(json) }

    it 'stores the institution info' do
      expect(subject.institution.name).to eq 'Stanford University'
    end

    it 'stores the campus info' do
      expect(subject.campus.name).to eq 'Stanford Libraries'
    end

    it 'stores the library info' do
      expect(subject.library.code).to eq 'GREEN'
    end

    it 'stores the location info' do
      expect(subject.name).to eq 'Green Bender Room'
    end
  end
end
