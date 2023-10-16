require 'rails_helper'

RSpec.describe LiveLookupIds do
  describe '#live_lookup_id' do
    context 'document has a uuid' do
      let(:document) { SolrDocument.new(id: '11111', uuid_ssi: 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f') }

      it 'returns the instance record uuid' do
        expect(document.live_lookup_id).to eq 'ac0f8371-13ab-55c6-9fcc-1c95bc4fe39f'
      end
    end
  end
end
