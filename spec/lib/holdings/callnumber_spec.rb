require "spec_helper"

describe Holdings::Callnumber do
  let(:complex_item_display) {
    'barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- callnumber -|- full_shelfkey -|- course_id -|- reserve_desk -|- loan_period'
  }
  let(:callnumber) { Holdings::Callnumber.new(complex_item_display) }
  let(:methods) { [:barcode, :library, :home_location, :current_location, :type, :truncated_callnumber, :shelfkey, :reverse_shelfkey, :callnumber, :full_shelfkey, :course_id, :reserve_desk, :loan_period] }
  it "should have an attribute for each piece of the item display field" do
    methods.each do |method|
      expect(callnumber).to respond_to(method)
    end
  end
  describe "#status" do
    let(:status) { callnumber.status }
    it "should return a Holdings::Status object" do
      expect(status).to be_a Holdings::Status
    end
    it "should return an availability_class string" do
      expect(status.availability_class).to eq 'unknown'
    end
  end
  describe "treat_current_location_as_home_location?" do
    it "should return true if an item's current location is in the list of locations" do
      Constants::CURRENT_HOME_LOCS.each do |location|
        expect(Holdings::Callnumber.new("barcode -|- library -|- home_location -|- #{location} -|-").treat_current_location_as_home_location?).to be_true
      end
    end
    it "should replace the home location with the current location" do
      expect(Holdings::Callnumber.new("barcode -|- library -|- home_location -|- IC-DISPLAY -|-").home_location).to eq "IC-DISPLAY"
    end
  end
  describe "reserves" do
    it "should use the pseudo home location if an item is has a reserve desk current location" do
      expect(Holdings::Callnumber.new("barcode -|- library -|- home_location -|- ART-RESV -|-").home_location).to eq "SW-RESERVE-DESK"
    end
    it "should change the library for an item that is at a reserve desk" do
      expect(Holdings::Callnumber.new("barcode -|- GREEN -|- home_location -|- ART-RESV -|-").library).to eq "ART"
    end
  end
  describe "#on_reserve?" do
    it "should return true when an item is populated with reserve desks and loan period" do
      expect(callnumber).to be_on_reserve
    end
    it "should return false when an item is not populated with reserve desk and loan period" do
      expect(Holdings::Callnumber.new('123 -|- abc')).to_not be_on_reserve
    end
  end
  describe "request status" do
    it "should respond to #requestable? from the Holdings::Requestable class" do
      expect(Holdings::Callnumber.new('123 -|- abc -|- -|- -|- -|-')).to be_requestable
    end
    it "should respond to #must_request? from the Holdings::Requestable class" do
      expect(Holdings::Callnumber.new('123 -|- abc -|- -|- -|- -|-')).to_not be_must_request
    end
  end
end
