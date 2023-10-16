# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchTips do
  subject(:search_tips) { described_class.new }

  describe 'initialization' do
    it 'allows an array of label/body objects to be injected' do
      configured_tips = [double(label: 'Tip Label', body: 'Tip Body')]
      tips = described_class.new(configured_tips)

      expect(tips.random.label).to eq 'Tip Label'
      expect(tips.random.body).to eq 'Tip Body'
    end
  end

  describe '#random' do
    it 'is a SearchTips::Tip' do
      expect(search_tips.random).to be_a SearchTips::Tip
    end

    it 'is random' do
      random_tips = Array.new(15) { search_tips.random.label }

      expect(random_tips.uniq.length).to be > 1
    end
  end

  describe 'Tip' do
    let(:tip) { described_class.random }

    describe '#label' do
      it { expect(tip.label).to be_present }
      it { expect(tip.label).to be_a String }
    end

    describe '#body' do
      it { expect(tip.body).to be_present }
      it { expect(tip.body).to be_a String }
    end
  end
end
