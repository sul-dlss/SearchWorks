# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FolioClient do
  subject(:client) { described_class.new(url:) }

  let(:url) { 'https://okapi.example.edu' }

  before do
    stub_request(:post, 'https://okapi.example.edu/authn/login')
      .to_return(headers: { 'x-okapi-token': 'tokentokentoken' }, status: 201)
  end

  describe '#real_time_availability' do
    before do
      stub_request(:post, 'https://okapi.example.edu/rtac-batch')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'holdings' =>
        [{ 'instanceId' => '9af85395-3104-5fc9-88ab-15554765c2d2',
           'holdings' =>
           [{ 'id' => 'aec715cd-4fd1-535a-975b-adf53c211800',
              'location' => 'Green Library Stacks',
              'callNumber' => 'PS3537 .A832 J68',
              'status' => 'Checked out',
              'dueDate' => '2024-07-02T06:59:59.000+00:00',
              'permanentLoanType' => 'Can circulate' }] }] }.to_json
    end
    let(:instance_ids) { ['9af85395-3104-5fc9-88ab-15554765c2d2'] }

    it 'returns a real time availability check response' do
      expect(client.real_time_availability(instance_ids:)).to have_key('holdings')
    end
  end
end
