require 'spec_helper'

RSpec.describe LocationRequestLinkPolicy do
  subject(:policy) { described_class.new(location:, library:, items:) }

  let(:location) { 'HOOVER' }
  let(:library) { 'STACKS' }

  describe '#aeon_pageable?' do
    subject { policy.aeon_pageable? }

    context 'when there are no items' do
      # Seen in a404313 for HOOVER/STACKS where it says "Scattered issues missing"
      let(:items) { [] }

      it { is_expected.to be true }
    end
  end
end
