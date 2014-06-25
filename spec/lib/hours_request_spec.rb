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

  it "should not make an API request for a library w/o public access" do
    expect(Faraday).not_to receive(:new)
    HoursRequest.new("SAL3").get
  end
  it "should return a JSON error if the library is not real" do
    expect(JSON.parse(HoursRequest.new("NOT-A-REAL-LIBRARY").get)).to eq({'error' => 'No public access'})
  end

  it "should receive " do
    # Fake URL that resolves for testing
    expect(Faraday).to receive(:new).with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(struct)
    expect(HoursRequest.new("GREEN").get).to eq("test")
  end

end
