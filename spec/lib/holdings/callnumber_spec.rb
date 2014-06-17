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
end
