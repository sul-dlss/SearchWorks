# frozen_string_literal: true

require 'rails_helper'

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

  describe '#circulation_rules' do
    before do
      stub_request(:get, 'https://okapi.example.edu/circulation-rules-storage')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'rulesAsText' => 'circulation rules' }.to_json
    end

    it 'returns the circulation rules' do
      expect(client.circulation_rules).to eq 'circulation rules'
    end
  end

  describe '#request_policies' do
    before do
      stub_request(:get, 'https://okapi.example.edu/request-policy-storage/request-policies?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'requestPolicies' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.request_policies).to include(hash_including('id' => '1'))
    end
  end

  describe '#loan_policies' do
    before do
      stub_request(:get, 'https://okapi.example.edu/loan-policy-storage/loan-policies?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'loanPolicies' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.loan_policies).to include(hash_including('id' => '1'))
    end
  end

  describe '#lost_item_fees_policies' do
    before do
      stub_request(:get, 'https://okapi.example.edu/lost-item-fees-policies?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'lostItemFeePolicies' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.lost_item_fees_policies).to include(hash_including('id' => '1'))
    end
  end

  describe '#overdue_fines_policies' do
    before do
      stub_request(:get, 'https://okapi.example.edu/overdue-fines-policies?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'overdueFinePolicies' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.overdue_fines_policies).to include(hash_including('id' => '1'))
    end
  end

  describe '#patron_notice_policies' do
    before do
      stub_request(:get, 'https://okapi.example.edu/patron-notice-policy-storage/patron-notice-policies?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'patronNoticePolicies' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.patron_notice_policies).to include(hash_including('id' => '1'))
    end
  end

  describe '#patron_groups' do
    before do
      stub_request(:get, 'https://okapi.example.edu/groups?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'usergroups' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.patron_groups).to include(hash_including('id' => '1'))
    end
  end

  describe '#material_types' do
    before do
      stub_request(:get, 'https://okapi.example.edu/material-types?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'mtypes' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.material_types).to include(hash_including('id' => '1'))
    end
  end

  describe '#loan_types' do
    before do
      stub_request(:get, 'https://okapi.example.edu/loan-types?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'loantypes' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.loan_types).to include(hash_including('id' => '1'))
    end
  end

  describe '#libraries' do
    before do
      stub_request(:get, 'https://okapi.example.edu/location-units/libraries?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'loclibs' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.libraries).to include(hash_including('id' => '1'))
    end
  end

  describe '#campuses' do
    before do
      stub_request(:get, 'https://okapi.example.edu/location-units/campuses?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'loccamps' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.campuses).to include(hash_including('id' => '1'))
    end
  end

  describe '#institutions' do
    before do
      stub_request(:get, 'https://okapi.example.edu/location-units/institutions?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'locinsts' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.institutions).to include(hash_including('id' => '1'))
    end
  end

  describe '#locations' do
    before do
      stub_request(:get, 'https://okapi.example.edu/locations?limit=2147483647')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body:)
    end

    let(:body) do
      { 'locations' => [{ 'id' => '1' }] }.to_json
    end

    it 'returns the request policies' do
      expect(client.locations).to include(hash_including('id' => '1'))
    end
  end
end
