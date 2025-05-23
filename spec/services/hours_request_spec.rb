# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoursRequest do
  let(:library) { "GREEN" }
  let(:hours_request) { described_class.new(library) }

  describe '#find_library' do
    subject { hours_request.find_library }

    it { is_expected.to eq 'green/location/green_library' }
  end

  describe '#get' do
    subject(:get) { hours_request.get }

    before do
      allow(Settings.HOURS_API).to receive(:enabled).and_return(true)
      stub_request(:get, "http://example.com/green/location/green_library/hours/for/today")
        .to_return(status: 200, body: "test", headers: {})
    end

    it "calls the remote API" do
      expect(get).to eq("test")
    end

    context 'with a library w/o public access' do
      let(:library) { 'SAL3' }

      it "does not make an API request" do
        expect(Faraday).not_to receive(:new)
        get
      end
    end
  end
end
