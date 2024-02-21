require 'rails_helper'

RSpec.describe Holdings::Item do
  let(:complex_item_display) do
    {
      barcode: '123', library: 'library', home_location: 'home_location', current_location: 'current_location', type: 'type',
      truncated_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'callnumber',
      full_shelfkey: 'full_shelfkey', public_note: 'public_note', scheme: 'callnumber_type',
      course_id: 'course_id', reserve_desk: 'reserve_desk', loan_period: 'loan_period'
    }
  end
  let(:item) { Holdings::Item.new(complex_item_display) }
  let(:methods) { [:barcode, :library, :home_location, :current_location, :type, :truncated_callnumber, :shelfkey, :reverse_shelfkey, :callnumber, :full_shelfkey, :public_note, :callnumber_type, :course_id, :reserve_desk, :loan_period] }
  let(:internet_item) { Holdings::Item.new({ library: 'SUL', home_location: 'INTERNET', shelfkey: 'abc123', reverse_shelfkey: 'xyz987', scheme: 'LC' }) }
  let(:eresv_item) { Holdings::Item.new({ library: 'SUL', home_location: 'INSTRUCTOR', current_location: 'E-RESV', shelfkey: 'abc123', reverse_shelfkey: 'xyz987', scheme: 'LC' }) }

  it 'should have an attribute for each piece of the item display field' do
    methods.each do |method|
      expect(item).to respond_to(method)
    end
  end
  describe '#suppressed?' do
    let(:no_item_display) { Holdings::Item.new({}) }

    it "should be true when the item_display doesn't exist" do
      expect(no_item_display).to be_suppressed
    end

    it 'should return false when the item_display exists' do
      expect(item).not_to be_suppressed
    end

    it 'should return true for INTERNET items' do
      expect(internet_item).to be_suppressed
    end

    it 'should return true for E-RESVs' do
      expect(eresv_item).to be_suppressed
    end
  end

  describe '#full_shelfkey' do
    it 'returns the full shelfkey' do
      expect(item.full_shelfkey).to eq('full_shelfkey')
    end

    it 'returns a string that sorts last if there is no shelfkey in the data' do
      expect(internet_item.full_shelfkey).to eq Holdings::Item::MAX_SHELFKEY
    end
  end

  describe '#on_order?' do
    it 'should return true for on-order items' do
      expect(Holdings::Item.new({ status: 'On order' })).to be_on_order
    end

    it 'should return false for non on-order items' do
      expect(item).not_to be_on_order
    end
  end

  describe 'browsable?' do
    it 'should return false if not LC or DEWEY' do
      expect(Holdings::Item.new(complex_item_display)).not_to be_browsable
    end

    it 'should return false if there is no shelfkey' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'ABC123', scheme: 'LC' })).not_to be_browsable
    end

    it 'should return false if there is no reverse shelfkey' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', shelfkey: 'shelfkey', callnumber: 'ABC123', scheme: 'LC' })).not_to be_browsable
    end

    it 'should return true if callnumber type is ALPHANUM' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'ABC123', scheme: 'ALPHANUM' })).to be_browsable
    end

    it 'should return false if callnumber type is INTERNET' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'ABC123', scheme: 'INTERNET' })).not_to be_browsable
    end
    it 'should return true if callnumber type is LC' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'ABC123', scheme: 'LC' })).to be_browsable
    end

    it 'should return true if callnumber type is DEWEY' do
      expect(described_class.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', callnumber: 'ABC123', scheme: 'DEWEY' })).to be_browsable
    end

    it 'should return true if the item is an internet resource' do
      expect(internet_item).to be_browsable
    end
  end

  describe '#callnumber' do
    let(:item_without_callnumber) { Holdings::Item.new({ barcode: 'barcode', library: 'library', home_location: 'home_location', current_location: 'current_location', type: 'type', lopped_callnumber: 'truncated_callnumber', shelfkey: 'shelfkey', reverse_shelfkey: 'reverse_shelfkey', full_shelfkey: 'full_shelfkey' }) }
    let(:lane_online_item) { Holdings::Item.new({ library: 'LANE-MED', home_location: 'LANE-ECOLL', type: 'ONLINE', shelfkey: 'abc123', reverse_shelfkey: 'xyz987', scheme: 'LC' }) }

    it "should return '(no call number) if the callnumber is blank" do
      expect(item_without_callnumber.callnumber).to eq '(no call number)'
    end

    it 'returns "eResource" when the home location is INTERNET' do
      expect(internet_item.callnumber).to eq 'eResource'
    end

    it 'returns "eResource" when the item type is ONLINE' do
      expect(lane_online_item.callnumber).to eq 'eResource'
    end
  end

  describe '#status' do
    let(:status) { item.status }

    it 'should return a Holdings::Status object' do
      expect(status).to be_a Holdings::Status
    end

    it 'should return an availability_class string' do
      expect(status.availability_class).to eq 'unknown'
    end
  end

  describe 'public_note' do
    let(:public_note) { Holdings::Item.new({ note: '.PUBLIC. The Public Note' }) }

    it 'should remove the .PUBLIC. string from the public note field' do
      expect(public_note.public_note).to eq 'The Public Note'
      expect(public_note.public_note).not_to include 'PUBLIC'
    end
  end

  describe 'reserves' do
    it 'should change the library for an item that is at a reserve desk' do
      expect(described_class.new({ barcode: 'barcode', library: 'GREEN', home_location: 'home_location', current_location: 'ART-RESV' })).to have_attributes(library: 'ART')
    end
  end

  describe '#on_reserve?' do
    it 'should return true when an item is populated with reserve desks and loan period' do
      expect(item).to be_on_reserve
    end

    it 'should return false when an item is not populated with reserve desk and loan period' do
      expect(described_class.new({ barcode: '123', library: 'abc' })).not_to be_on_reserve
    end
  end

  describe 'zombie libraries' do
    let(:blank) { Holdings::Item.new({ barcode: '123', library: '', home_location: 'LOCATION' }) }

    it 'should view blank libraries as a zombie library' do
      expect(blank.library).to eq 'ZOMBIE'
    end
  end

  describe '#as_json' do
    let(:as_json) { Holdings::Item.new(complex_item_display).as_json }

    it "should return a hash with all of the item's public reader methods" do
      expect(as_json).to be_a Hash
      expect(as_json[:callnumber]).to eq 'callnumber'
    end

    it 'should return an as_json hash for status' do
      expect(as_json[:status]).to be_a Hash
      expect(as_json[:status]).to have_key :availability_class
      expect(as_json[:status]).to have_key :status_text
    end

    it 'should return an as_json hash for current_location' do
      expect(as_json[:current_location]).to be_a Hash
      expect(as_json[:current_location]).to have_key :code
      expect(as_json[:current_location]).to have_key :name
    end
  end

  context 'with data from FOLIO' do
    let(:folio_item) {
      Folio::Item.from_dynamic({
                                 'id' => '64d4220b-ebae-5fb0-971c-0f98f6d9cc93',
                                 'status' => 'Available',
                                 'barcode' => '36105232609540',
                                 'materialType' => 'book',
                                 'materialTypeId' => '1a54b431-2e4f-452d-9cae-9cee66c9a892',
                                 'permanentLoanType' => 'Can circulate',
                                 'permanentLoanTypeId' => '2b94c631-fca9-4892-a730-03ee529ffe27',
                                 'callNumber' => { 'typeId' => "95467209-6d7b-468b-94df-0f5d7ad2747d",
                                                   'typeName' => "Library of Congress classification",
                                                   'callNumber' => "PN1995.9.M6 A76 2024" },
                                 'location' => { 'effectiveLocation' => folio_location }
                               })
    }
    let(:folio_location) {
      {
        'id' => '4573e824-9273-4f13-972f-cff7bf504217',
        'code' => 'GRE-STACKS',
        'name' => 'Green Library Stacks',
        'institution' => {
          'id' => '8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929',
          'code' => 'SU',
          'name' => 'Stanford University'
        },
        'campus' => {
          'id' => 'c365047a-51f2-45ce-8601-e421ca3615c5',
          'code' => 'SUL',
          'name' => 'Stanford Libraries'
        },
        'library' => {
          'id' => 'f6b5519e-88d9-413e-924d-9ed96255f72e',
          'code' => 'GREEN',
          'name' => 'Cecil H. Green'
        }
      }
    }

    let(:document) { SolrDocument.new }

    subject(:item) { described_class.new({ barcode: '36105232609540', library: 'GREEN', home_location: 'GRE-STACKS' }, document:) }

    before do
      allow(document).to receive(:folio_items).and_return([folio_item])
    end

    describe '#material_type' do
      it 'returns the material type from FOLIO' do
        expect(item.material_type.name).to eq 'book'
      end
    end

    describe '#loan_type' do
      it 'returns the loan type from FOLIO' do
        expect(item.loan_type.name).to eq 'Can circulate'
      end
    end

    describe '#effective_location' do
      it 'returns the effective location from FOLIO' do
        expect(item.effective_location.library.code).to eq 'GREEN'
        expect(item.effective_location.code).to eq 'GRE-STACKS'
      end
    end

    describe '#live_lookup_item_id' do
      it 'returns the item uuid from FOLIO' do
        expect(item.live_lookup_item_id).to eq '64d4220b-ebae-5fb0-971c-0f98f6d9cc93'
      end
    end

    describe '#live_lookup_instance_id' do
      context 'with a regular (not bound-with) item'
      it 'returns nil' do
        expect(item.live_lookup_instance_id).to be_nil
      end
    end
  end

  context 'with a FOLIO bound-with' do
    let(:document) {
      SolrDocument.new(
        id: '1234',
        holdings_json_struct: [
          { holdings: [
            {
              id: 'holding1234',
              location: {
                effectiveLocation: {
                  id: "4573e824-9273-4f13-972f-cff7bf504217",
                  code: "SEE-OTHER",
                  name: "Bound With Test",
                  campus: {
                    id: "c365047a-51f2-45ce-8601-e421ca3615c5",
                    code: "SUL",
                    name: "Stanford Libraries"
                  },
                  details: {},
                  library: {
                    id: "f6b5519e-88d9-413e-924d-9ed96255f72e",
                    code: "GREEN",
                    name: "Cecil H. Green"
                  },
                  institution: {
                    id: "8d433cdd-4e8f-4dc1-aa24-8a4ddb7dc929",
                    code: "SU",
                    name: "Stanford University"
                  }
                }
              },
              holdingsType: {
                id: "5b08b35d-aaa3-4806-998c-9cd85e5bc406",
                name: "Bound-with"
              },
              boundWith: {
                item: { barcode: "1234" },
                instance: { id: "7e194e58-e134-56fe-a3c2-2c0494e04c5b" }
              }
            }
          ] }
        ]
      )
    }

    subject(:item) { described_class.new({ barcode: '1234', library: 'GREEN', home_location: 'GRE-STACKS' }, document:) }

    describe '#live_lookup_instance_id' do
      context 'with a bound-with item'
      it 'returns the parent instance id' do
        expect(item.live_lookup_instance_id).to eq "7e194e58-e134-56fe-a3c2-2c0494e04c5b"
      end
    end
  end
end
