require 'rails_helper'

##
# Stimple test class to model a
# network of singleton and IP ranges
class TestIPNetwork
  def singletons
    ['172.22.45.195', '172.35.0.0/16']
  end

  def ranges
    [
      ['171.10.15.7', '171.10.15.35'],
      ['171.12.0.0', '171.15.255.255']
    ]
  end
end

RSpec.describe IPRange do
  let(:test_network) { TestIPNetwork.new }

  context 'singletons' do
    it 'IP addresses configured as a single address are properly identified' do
      expect(described_class.new('172.22.45.195', test_network)).to be_included
      expect(described_class.new('172.22.45.196', test_network)).not_to be_included
    end

    it 'IP addresses configured in a range with a slash suffix are properly identified' do
      expect(described_class.new('172.34.255.255', test_network)).not_to be_included
      expect(described_class.new('172.35.0.0', test_network)).to be_included
      expect(described_class.new('172.35.100.100', test_network)).to be_included
      expect(described_class.new('172.35.255.255', test_network)).to be_included
      expect(described_class.new('172.36.0.0', test_network)).not_to be_included
    end
  end

  context 'ranges' do
    it 'IP addresses configured as custom ranges are properly identified' do
      expect(described_class.new('171.10.15.6', test_network)).not_to be_included
      expect(described_class.new('171.10.15.7', test_network)).to be_included
      expect(described_class.new('171.10.15.20', test_network)).to be_included
      expect(described_class.new('171.10.15.35', test_network)).to be_included
      expect(described_class.new('171.10.15.36', test_network)).not_to be_included

      expect(described_class.new('171.11.255.255', test_network)).not_to be_included
      expect(described_class.new('171.12.0.0', test_network)).to be_included
      expect(described_class.new('171.14.100.100', test_network)).to be_included
      expect(described_class.new('171.15.255.255', test_network)).to be_included
      expect(described_class.new('171.16.0.0', test_network)).not_to be_included
    end
  end
end
