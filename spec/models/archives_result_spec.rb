# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArchivesResult do
  describe '#icon' do
    it 'ignores the format case' do
      expect(described_class.new(type: 'Collection').icon).to eq('archive.svg')
    end
  end
end
