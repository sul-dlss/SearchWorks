# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Specialist do
  describe '.find' do
    it 'returns a specialist matching the query' do
      expect(described_class.find('British History')).to have_attributes(title: 'Benjamin Stone')
    end

    it 'returns a specialist using a partial match' do
      expect(described_class.find('Rare unmatchedtoken Curator')).to have_attributes(title: 'Benjamin Albritton')
    end
  end
end
