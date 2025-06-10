# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbstractSearchService do
  describe AbstractSearchService::Result do
    subject(:result) { described_class.new }

    describe '#title' do
      subject { result.title }

      it { is_expected.to be_nil }
    end
  end
end
