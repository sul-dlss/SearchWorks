require 'rails_helper'

RSpec.describe Folio::LocationsMap do
  describe '.symphony_code_for' do
    it 'returns the Symphony location code for a given Folio location' do
      expect(Folio::LocationsMap.symphony_code_for(location_code: 'GRE-STACKS')).to eq(['GREEN', 'STACKS'])
      expect(Folio::LocationsMap.symphony_code_for(location_code: 'SAL3-STACKS')).to eq(['SAL3', 'STACKS'])
      expect(Folio::LocationsMap.symphony_code_for(location_code: 'LANE-LAN')).to eq(['LANE-MED', 'LANE-LAN'])
    end
  end
end
