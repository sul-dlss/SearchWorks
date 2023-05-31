# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FolioClient do
  subject(:client) { described_class.new(url:) }

  let(:url) { 'https://example.com' }

  before do
    stub_request(:post, 'https://example.com/authn/login')
      .to_return(headers: { 'x-okapi-token': 'tokentokentoken' }, status: 201)
  end

  describe '#post' do
    before do
      stub_request(:post, 'https://example.com/blah')
        .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
        .to_return(body: 'Hi!')
    end

    it 'sends a post request with okapi auth headers' do
      expect(client.post('/blah').body.to_s).to eq('Hi!')
    end

    context 'with a method' do
      before do
        stub_request(:post, 'https://example.com/blah')
          .with(headers: { 'x-okapi-token': 'tokentokentoken', 'X-Okapi-Tenant': 'sul' })
          .to_return(body: 'Hi!')
      end

      it 'overrides the request type' do
        expect(client.post('/blah', method: :post).body.to_s).to eq('Hi!')
      end
    end
  end

  describe '#post_json' do
    before do
      stub_request(:post, 'https://example.com/blah')
        .to_return(body:)
    end

    let(:body) { '{"hello": "world"}' }

    it 'parses json responses into ruby objects' do
      expect(client.post_json('/blah')).to eq('hello' => 'world')
    end

    describe 'when the response is empty' do
      let(:body) { '' }

      it 'returns nil' do
        expect(client.post_json('/blah')).to be_nil
      end
    end
  end

  describe '#rtac' do
    before do
      stub_request(:post, 'https://example.com/rtac-batch')
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
      expect(client.rtac(instance_ids:)).to have_key('holdings')
    end
  end
end
