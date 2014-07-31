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
  describe "#present?" do
    let(:no_item_display) { Holdings::Callnumber.new('') }
    it "should be false when the item_display doesn't exist" do
      expect(no_item_display).to_not be_present
    end
    it "should return true when the item_display exists" do
      expect(callnumber).to be_present
    end
  end
  describe "#on_order?" do
    it "should return true for on-order items" do
      expect(Holdings::Callnumber.new(' -|- -|- ON-ORDER -|- ON-ORDER -|-')).to be_on_order
    end
    it "should return false for non on-order items" do
      expect(callnumber).to_not be_on_order
    end
  end
  describe "browsable?" do
    it "should return true if there is a real callnumber" do
      expect(Holdings::Callnumber.new(complex_item_display)).to be_browsable
    end
    it "should return true if there false if there is no real callnumber" do
      expect(Holdings::Callnumber.new('-|- -|- -|-')).to_not be_browsable
    end
  end
  describe "#callnumber" do
    let(:no_callnumber) { Holdings::Callnumber.new('barcode -|- library -|- home_location -|- current_location -|- type -|- truncated_callnumber -|- shelfkey -|- reverse_shelfkey -|- -|- full_shelfkey ') }
    it "should return '(no callnumber) if the callnumber is blank" do
      expect(no_callnumber.callnumber).to eq '(no callnumber)'
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
  describe "zombie libraries" do
    let(:blank) { Holdings::Callnumber.new('123 -|- -|- LOCATION -|- ') }
    let(:sul) { Holdings::Callnumber.new('123 -|- SUL -|- LOCATION -|- ') }
    let(:physics) { Holdings::Callnumber.new('123 -|- PHYSICS -|- LOCATION -|- ') }
    it "should view blank libraries as a zombie library" do
      expect(blank.library).to eq "ZOMBIE"
    end
    it "should view blank libraries as a zombie library" do
      expect(sul.library).to eq "ZOMBIE"
    end
    it "should view blank libraries as a zombie library" do
      expect(physics.library).to eq "ZOMBIE"
    end
  end
end
