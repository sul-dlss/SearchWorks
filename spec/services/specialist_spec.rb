# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Specialist do
  describe '.find' do
    it 'returns specialists matching the query' do
      expect(described_class.find('British History').first).to have_attributes(name: 'Benjamin Stone')
    end

    it 'returns specialists using a partial match' do
      expect(described_class.find('Rare unmatchedtoken Curator').first).to have_attributes(name: 'Benjamin Albritton')
    end

    it 'returns nothing if no terms match' do
      expect(described_class.find('cats')).to be_nil
    end

    it 'returns nothing if the query term was a stopword' do
      expect(described_class.find('the')).to be_nil
    end

    it 'truncates apostrophes in search terms instead of treating it is a separate token' do
      expect(described_class.find("Black's Law Dictionary")).to be_blank
    end
  end
end
