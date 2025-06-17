# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Specialist do
  describe '.find' do
    it 'returns a specialist matching the query' do
      expect(described_class.find('British History')).to have_attributes(title: 'Benjamin Stone')
    end
  end
end
