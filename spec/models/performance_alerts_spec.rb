# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PerformanceAlerts do
  subject(:alerts) { described_class.new(policy_id: '12345') }

  describe '#open' do
    before do
      expect(alerts).to receive(:violations).at_least(:once).and_return(
        [
          # Closed
          {
            'test_id' => '1',
            'opened_at' => (Time.zone.now - 2.days).to_s,
            'closed_at' => (Time.zone.now - 1.day).to_s,
            'links' => { 'policy_id' => '12345' }
          },
          # Open
          {
            'test_id' => '2',
            'opened_at' => Time.zone.now - 5.minutes,
            'links' => { 'policy_id' => '12345' }
          },
          # Differnt policy id
          {
            'test_id' => '3',
            'opened_at' => Time.zone.now - 10.minutes,
            'links' => { 'policy_id' => 'not-the-right-id' }
          }
        ]
      )
    end

    it 'is an array of open alerts that for the given policy' do
      expect(alerts.open).to be_one
      expect(alerts.open.first['test_id']).to eq '2'
    end
  end

  describe 'errors' do
    context 'when the API connection fails' do
      let(:stub_http_client) do
        Class.new do
          def get(*)
            raise Faraday::ConnectionFailed, 'Raising a connection error from a test http client'
          end
        end
      end

      subject(:alerts) { described_class.new(policy_id: '12345', http_client: stub_http_client) }

      it 'returns no alerts' do
        expect(alerts.open).to be_blank
      end
    end

    # We don't check in an API key so we should be getting a 401 from them by default
    context 'when the API returns an unsuccessful response' do
      it 'returns no alerts' do
        expect(alerts.open).to be_blank
      end
    end

    context 'when the API return unparsable JSON' do
      before do
        expect(alerts).to receive(:response).and_return('<html/>')
      end

      it 'returns no alerts' do
        expect(alerts.open).to be_blank
      end
    end
  end
end
