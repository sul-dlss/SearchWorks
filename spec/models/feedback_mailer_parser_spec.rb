# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailerParser do
  describe '#name' do
    context 'when present' do
      it { expect(described_class.new({ name: 'yo' }, '').name).to eq 'yo' }
    end

    context 'when absent' do
      it { expect(described_class.new({}, '').name).to eq 'No name given' }
    end
  end

  describe '#email' do
    context 'when present' do
      it { expect(described_class.new({ to: 'yo' }, '').email).to eq 'yo' }
    end

    context 'when absent' do
      it { expect(described_class.new({}, '').email).to eq 'No email given' }
    end
  end

  describe '#message' do
    it 'casts to a String' do
      expect(described_class.new({}, '').message).to be_an String
    end
    it 'accesses :message' do
      expect(described_class.new({ message: 'yo' }, '').message).to eq 'yo'
    end
  end

  describe 'accessors' do
    subject do
      described_class.new(
        {
          url: 'http://www.example.com',
          user_agent: 'Yo',
          viewport: 'Lo',
          resource_name: 'Hey',
          problem_url: 'There',
          last_search: '/?q=kittenz'
        }, ''
      )
    end

    it 'calls and accesses params' do
      expect(subject.url).to eq 'http://www.example.com'
      expect(subject.user_agent).to eq 'Yo'
      expect(subject.viewport).to eq 'Lo'
      expect(subject.resource_name).to eq 'Hey'
      expect(subject.problem_url).to eq 'There'
      expect(subject.last_search).to eq '/?q=kittenz'
    end
  end
end
