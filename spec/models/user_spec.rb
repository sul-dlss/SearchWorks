# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:subject) { described_class.new }

  before do
    allow(subject).to receive(:email).and_return('jstanford@stanford.edu')
  end

  describe '#to_s' do
    it 'returns the email' do
      expect(subject.to_s).to eq 'jstanford@stanford.edu'
    end
  end

  describe '#sunet' do
    it 'returns just the SUNet part of the email address' do
      expect(subject.sunet).to eq 'jstanford'
    end
  end
end
