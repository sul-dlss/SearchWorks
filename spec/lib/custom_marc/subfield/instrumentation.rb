require 'spec_helper'

describe CustomMarc::Subfield::Instrumentation do
  let(:a) { CustomMarc::Subfield::Instrumentation.new('a', 'piano') }
  let(:b) { CustomMarc::Subfield::Instrumentation.new('b', 'piano') }
  let(:d) { CustomMarc::Subfield::Instrumentation.new('d', 'piano') }
  let(:n) { CustomMarc::Subfield::Instrumentation.new('n', '3') }
  let(:k) { CustomMarc::Subfield::Instrumentation.new('k', 'piano') }
  describe 'a_subfield' do
    it 'should return just the value' do
      expect(a.a_subfield).to eq 'piano'
    end
  end
  describe 'b_subfield' do
    it 'should return just the solo value' do
      expect(b.b_subfield).to eq 'solo piano'
    end
  end
  describe 'd_subfield' do
    it 'should return just the solo value' do
      expect(d.d_subfield).to eq 'doubling piano'
    end
  end
  describe 'n_subfield' do
    it 'should return just the solo value' do
      expect(n.n_subfield).to eq '(3)'
    end
  end
  describe 'k_subfield' do
    it 'should return just the solo value' do
      expect(k.k_subfield).to eq nil
    end
  end
end
