require 'rails_helper'

RSpec.describe LiveLookup::Solr do
  subject(:solr_live_lookup) { described_class.new(ids) }

  let(:rsolr) { instance_double(RSolr) }
  let(:rsolr_client) { instance_double(RSolr::Client) }

  before do
    allow(RSolr).to receive(:connect).and_return(rsolr_client)
    allow(rsolr_client).to receive(:get).and_return(response)
  end

  describe 'when the item is checked out' do
    let(:ids) { ['14409998'] }
    let(:response) do
      { 'responseHeader' =>
        { 'zkConnected' => true,
          'status' => 0,
          'QTime' => 5,
          'params' =>
          { 'mm' => '1',
            'q' => 'id:(14409998)',
            'fl' => 'id, item_display_struct',
            'q.op' => 'OR',
            'rows' => '100',
            'facet' => 'false',
            'wt' => 'json' } },
        'response' =>
        { 'numFound' => 1,
          'start' => 0,
          'numFoundExact' => true,
          'docs' =>
          [{ 'id' => '14409998',
             'item_display_struct' =>
             ['{"id":null,"barcode":"36105232537659","library":"GREEN","home_location":"STACKS","status":"Checked out",' \
              '"current_location":"STACKS","type":"STKS-MONO","lopped_callnumber":"BD375 .D8713 2023",' \
              '"shelfkey":"lc bd  0375.000000 d0.871300 002023","reverse_shelfkey":"en~om~~zwsu}zzzzzz~mz}rsywzz~zzxzxw~~~~~~~~~~~~~~~",' \
              '"callnumber":"BD375 .D8713 2023","full_shelfkey":"lc bd  0375.000000 d0.871300 002023","note":null,"scheme":"LC"}'] }] } }
    end

    it do
      expect(solr_live_lookup.records).to eq([{ item_id: '36105232537659',
                                                barcode: '36105232537659',
                                                due_date: nil,
                                                status: 'Checked out',
                                                current_location: 'STACKS',
                                                is_available: false }])
    end
  end

  describe 'when the item is at the bindery' do
    let(:ids) { ['14892534'] }
    let(:response) do
      { 'responseHeader' =>
        { 'zkConnected' => true,
          'status' => 0,
          'QTime' => 1,
          'params' =>
          { 'mm' => '1',
            'q' => 'id:(14892534)',
            'fl' => 'id, item_display_struct',
            'q.op' => 'OR',
            'rows' => '100',
            'facet' => 'false',
            'wt' => 'json' } },
        'response' =>
        { 'numFound' => 1,
          'start' => 0,
          'numFoundExact' => true,
          'docs' =>
          [{ 'id' => '14892534',
             'item_display_struct' =>
             ['{"id":null,"barcode":"36105232792999","library":"GREEN","home_location":"STACKS","status":"In process",' \
              '"current_location":"At bindery","type":"STKS-MONO","lopped_callnumber":"DK42 .P53 2024",' \
              '"shelfkey":"lc dk  0042.000000 p0.530000 002024","reverse_shelfkey":"en~mf~~zzvx}zzzzzz~az}uwzzzz~zzxzxv~~~~~~~~~~~~~~~",' \
              '"callnumber":"DK42 .P53 2024","full_shelfkey":"lc dk  0042.000000 p0.530000 002024","note":null,"scheme":"LC"}'] }] } }
    end

    it do
      expect(solr_live_lookup.records).to eq([{ item_id: '36105232792999',
                                                barcode: '36105232792999',
                                                due_date: nil,
                                                status: 'In process',
                                                current_location: 'At bindery',
                                                is_available: false }])
    end
  end

  describe 'when the item is available' do
    let(:ids) { ['908528'] }
    let(:response) do
      { 'responseHeader' =>
        { 'zkConnected' => true,
          'status' => 0,
          'QTime' => 1,
          'params' =>
          { 'mm' => '1',
            'q' => 'id:(908528)',
            'fl' => 'id, item_display_struct',
            'q.op' => 'OR',
            'rows' => '100',
            'facet' => 'false',
            'wt' => 'json' } },
        'response' =>
        { 'numFound' => 1,
          'start' => 0,
          'numFoundExact' => true,
          'docs' =>
          [{ 'id' => '908528',
             'item_display_struct' =>
             ['{"id":null,"barcode":"36105036611262","library":"SAL3","home_location":"STACKS","status":"Available",' \
              '"current_location":null,"type":"STKS-MONO","lopped_callnumber":"PS3537.A832.Z85",' \
              '"shelfkey":"lc ps  3537.000000 a0.832000 z0.850000","reverse_shelfkey":"en~a7~~wuws}zzzzzz~pz}rwxzzz~0z}ruzzzz~~~~~~~~~~~~",' \
              '"callnumber":"PS3537.A832.Z85","full_shelfkey":"lc ps  3537.000000 a0.832000 z0.850000","note":null,"scheme":"LC"}'] }] } }
    end

    it do
      expect(solr_live_lookup.records).to eq([{ item_id: '36105036611262',
                                                barcode: '36105036611262',
                                                due_date: nil,
                                                status: 'Available',
                                                current_location: nil,
                                                is_available: true }])
    end
  end
end
