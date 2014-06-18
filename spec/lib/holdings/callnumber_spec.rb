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
  describe "#on_reserve?" do
    it "should return true when an item is populated with reserve desks and loan period" do
      expect(callnumber).to be_on_reserve
    end
    it "should return false when an item is not populated with reserve desk and loan period" do
      expect(Holdings::Callnumber.new('123 -|- abc')).to_not be_on_reserve
    end
  end
end
