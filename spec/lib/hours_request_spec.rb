require 'spec_helper'
require 'constants'
describe HoursRequest do
  let(:library) { "GREEN" }
  let(:hours_request) { HoursRequest.new(library) }
  let(:struct) { OpenStruct.new(get: OpenStruct.new(body: "test")) }

  it "should initialize as HoursRequest object" do
    expect(hours_request).to be_an HoursRequest
  end

  it "should return correct library" do
    expect(hours_request.find_library).to eq 'green/location/green_library'
  end

  it "should receive " do
    # Fake URL that resolves for testing
    expect(Faraday).to receive(:new).with({ url: "http://test/green/location/green_library/hours/for/today" }).and_return(struct)
    expect(HoursRequest.new("GREEN").get).to eq("test")
  end

end
