require 'spec_helper'
require 'constants'
describe HoursRequest do
  let(:library) { "GREEN" }
  let(:hours_request) { described_class.new(library) }

  it "should initialize as HoursRequest object" do
    expect(hours_request).to be_an described_class
  end

  it "should return correct library" do
    expect(hours_request.find_library).to eq 'green/location/green_library'
  end

  it "should not make an API request for a library w/o public access" do
    expect(Faraday).not_to receive(:new)
    described_class.new("SAL3").get
  end
  it "should return a JSON error if the library is not real" do
    expect(JSON.parse(described_class.new("NOT-A-REAL-LIBRARY").get)).to eq({'error' => 'No public access'})
  end

  it "should receive " do
    # Fake URL that resolves for testing
    expect(Faraday).to receive(:new).with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(double(get: double(body: 'test' )))
    expect(described_class.new("GREEN").get).to eq("test")
  end

end
