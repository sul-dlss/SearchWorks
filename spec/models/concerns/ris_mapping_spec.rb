# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RisMapping do
  describe '#field_mapping?' do
    it 'has expected keys' do
      expect(described_class.field_mapping.keys).to eq %i[TY TI AU PB KW LA Y1 CY AB C3 CN H1 SN DP UR L3]
    end
  end
end
