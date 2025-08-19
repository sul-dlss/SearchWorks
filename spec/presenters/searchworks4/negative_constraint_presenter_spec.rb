# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::NegativeConstraintPresenter, type: :presenter do
  subject(:presenter) do
    described_class.new(nil)
  end

  describe '#prefix' do
    it 'returns the prefix for inclusive facets' do
      expect(presenter.prefix).to eq('Excludes <span class="fw-bold">ALL</span>')
    end
  end
end
