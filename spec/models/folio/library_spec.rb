# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Folio::Library do
  describe '#new' do
    context 'with no institution' do
      subject(:library) { described_class.new(id: 'uuid', code: 'baz') }

      it 'uses the default institution' do
        expect(subject).to have_attributes(id: 'uuid', code: 'baz')
      end
    end
  end

  describe '#name' do
    subject(:library) { described_class.new(id: 'f6b5519e-88d9-413e-924d-9ed96255f72e', code: 'baz', name: 'foo') }

    it 'uses the cached name if available' do
      expect(library.name).to eq 'Green Library'
    end

    context 'when the library is not cached' do
      subject(:library) { described_class.new(id: 'uuid', code: 'baz', name: 'SAL4') }

      it 'uses the cached name if available' do
        expect(library.name).to eq 'SAL4'
      end
    end
  end
end
