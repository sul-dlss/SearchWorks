require "spec_helper"

describe FolioLiveLookup do
  subject(:folio_live_lookup) { described_class.new(ids) }

  let(:ids) { ['0a2dad05-e325-57ff-a61a-4cd34c133e2f'] }

  before do
    allow(folio_live_lookup).to receive(:folio_rtac_request).and_return(response)
  end

  describe 'when the status is available' do
    let(:response) do
      { "holdings" =>
        [{ "instanceId" => "0a2dad05-e325-57ff-a61a-4cd34c133e2f",
           "holdings" =>
           [{ "id" => "9c130866-f1a4-53fb-b390-30ac35b00388",
              "location" => "Green Library Stacks",
              "callNumber" => "BQ974 .A3588 B73 2013",
              "status" => "Available",
              "permanentLoanType" => "Can circulate" }] }] }
    end

    it {
      expect(folio_live_lookup.as_json).to eq(
        [{ "current_location" => nil, "due_date" => nil, "item_id" => "9c130866-f1a4-53fb-b390-30ac35b00388" }]
      )
    }
  end
end
