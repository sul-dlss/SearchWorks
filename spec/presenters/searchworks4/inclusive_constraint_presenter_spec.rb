# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searchworks4::InclusiveConstraintPresenter, type: :presenter do
  subject(:presenter) do
    described_class.new(nil)
  end

  describe '#prefix' do
    it 'returns the prefix for inclusive facets' do
      expect(presenter.prefix).to eq('Includes <span class="fw-bold">ANY</span>')
    end
  end
end
