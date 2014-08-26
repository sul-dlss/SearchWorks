require 'spec_helper'
require 'constants'
describe HoursRequest do
  let(:library) { "GREEN" }
  let(:hours_request) { HoursRequest.new(library) }
  let(:struct) { OpenStruct.new(get: OpenStruct.new(body: '[{ "opens_at": "2014-08-26T08:30:00-07:00", "closes_at": "2014-08-26T17:00:00-07:00" }]')) }

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
    expect(JSON.parse(HoursRequest.new("NOT-A-REAL-LIBRARY").get)).to eq([{'error' => 'No public access'}])
  end

  describe '#get' do
    it "should receive recieve a url and return the body response" do
      # Fake URL that resolves for testing
      expect(Faraday).to receive(:new).at_least(1).times.with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(struct)
      expect(HoursRequest.new("GREEN").get).to eq "[{ \"opens_at\": \"2014-08-26T08:30:00-07:00\", \"closes_at\": \"2014-08-26T17:00:00-07:00\" }]"
    end
  end

  describe '#opens_at' do
    it 'should return correct opening hours' do
      expect(Faraday).to receive(:new).at_least(1).times.with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(struct)
      expect(hours_request.opens_at).to eq (' 8:30am')
    end
  end

  describe '#closes_at' do
    it 'should return correct xlosing hours' do
      expect(Faraday).to receive(:new).at_least(1).times.with({ url: "http://example.com/green/location/green_library/hours/for/today" }).and_return(struct)
      expect(hours_request.closes_at).to eq (' 5:00pm')
    end
  end

end
