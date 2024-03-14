# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoursRequest do
  let(:library) { "GREEN" }
  let(:hours_request) { HoursRequest.new(library) }
  let(:struct) { OpenStruct.new(get: OpenStruct.new(body: "test")) }

  it "returns correct library" do
    expect(hours_request.find_library).to eq 'green/location/green_library'
  end

  it "does not make an API request for a library w/o public access" do
    expect(Faraday).not_to receive(:new)
    HoursRequest.new("SAL3").get
  end

  it "calls the remote API" do
    # Fake URL that resolves for testing
    expect(Settings.HOURS_API).to receive(:enabled).and_return(true)
    expect(Faraday).to receive(:new).with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(struct)
    expect(HoursRequest.new("GREEN").get).to eq("test")
  end
end
