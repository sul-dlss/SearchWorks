# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLinkFactory do
  subject(:factory) { described_class }

  context 'default behavior' do
    it do
      expect(factory.for(library: 'GREEN', location: 'STACKS')).to eq RequestLink
    end
  end

  context 'for Hoover' do
    it do
      expect(factory.for(library: 'HOOVER', location: 'STACKS')).to eq RequestLinks::HooverRequestLink
    end
  end

  context 'for Hoover Archives' do
    it do
      expect(factory.for(library: 'HV-ARCHIVE', location: 'STACKS')).to eq RequestLinks::HooverArchiveRequestLink
    end
  end

  pending 'for SSRC-DATA' do
    it do
      expect(factory.for(library: 'GREEN', location: 'SSRC-DATA')).to eq RequestLinks::SsrcDataRequestLink
    end
  end
end
