require 'rails_helper'

RSpec.describe LiveLookup::Folio do
  subject(:folio_live_lookup) { described_class.new(instance_ids) }

  let(:folio_client) { instance_double(FolioClient) }
  let(:instance_ids) { ['0a2dad05-e325-57ff-a61a-4cd34c133e2f'] }
  let(:response) do
    { 'holdings' =>
      [{ 'instanceId' => '0a2dad05-e325-57ff-a61a-4cd34c133e2f',
         'holdings' =>
         [{ 'id' => '9c130866-f1a4-53fb-b390-30ac35b00388',
            'location' => 'Green Library Stacks',
            'callNumber' => 'BQ974 .A3588 B73 2013',
            'status' => status,
            'dueDate' => due_date,
            'permanentLoanType' => 'Can circulate' }] }] }
  end
  let(:status) { 'Available' }
  let(:due_date) { nil }

  before do
    allow(FolioClient).to receive(:new).and_return(folio_client)
    allow(folio_client).to receive(:real_time_availability).with(instance_ids:).and_return(response)
  end

  describe 'when the item is available' do
    it {
      expect(folio_live_lookup.as_json).to eq(
        [{ 'item_id' => '9c130866-f1a4-53fb-b390-30ac35b00388',
           'due_date' => nil,
           'status' => nil,
           'is_available' => true }]
      )
    }
  end

  describe 'when the item is checked out' do
    let(:status) { 'Checked out' }
    let(:due_date) { '2023-11-03T06:59:59.000+00:00' }

    it 'is not available' do
      expect(folio_live_lookup.as_json.first['is_available']).to be false
    end

    it 'is "Checked out"' do
      expect(folio_live_lookup.as_json.first['status']).to eq 'Checked out'
    end

    it 'has a due date' do
      expect(folio_live_lookup.as_json.first['due_date']).to eq '11/02/2023'
    end
  end

  describe 'when FOLIO returns a status we want to display differently' do
    let(:status) { 'Awaiting pickup' }

    it 'translates the status' do
      expect(folio_live_lookup.as_json.first['status']).to eq 'On hold for a borrower'
    end
  end
end
