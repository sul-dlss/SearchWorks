require "spec_helper"

describe Holdings::Requestable do
  describe "requestable?" do
    describe "item types" do
      it "should not be requestable if the item-type begins with 'NH-'" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new('123 -|- GREEN -|- STACKS -|- -|- NH-SOMETHING'))).to_not be_requestable
      end
      it "should not be requestable if the item type is non-requestable" do
        ["REF","NONCIRC","LIBUSEONLY"].each do |type|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- -|- #{type} -|-"))).to_not be_requestable
        end
      end
    end
    describe 'reserves' do
      it 'should not be requestable if the item is on reserve' do
        expect(
          Holdings::Requestable.new(
            Holdings::Callnumber.new(
              '1234 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC123 -|- -|- -|- -|- course_id -|- reserve_desk -|- loan_period'
            )
          )
        ).to_not be_requestable
      end
    end
    describe "home locations" do
      it "should not be requestable if the library is GREEN and the home location is MEDIA-MTXT" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new('123 -|- GREEN -|- MEDIA-MTXT -|- -|- -|- '))).to_not be_requestable
      end
    end
    describe "current locations" do
      it "should be not requestable if in the list of current locations" do
        Constants::NON_REQUESTABLE_CURRENT_LOCS.each do |location|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- "))).to_not be_requestable
        end
      end
    end
    describe "location level requests" do
      it "libraries that are requestable at the location level should not be requestable" do
        Constants::REQUEST_LIBS.each do |library|
          expect(Holdings::Requestable.new(OpenStruct.new(library: library))).to_not be_requestable
        end
      end
    end
  end
  describe "must_request?" do
    describe "current locations" do
      it "should require -LOAN current locations to be requested" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SOMETHING-LOAN -|- "))).to be_must_request
      end
      it "should not require SEE-LOAN current locations to be requested" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SEE-LOAN -|- "))).to_not be_must_request
      end
      it "should require the list of request current locations to be requested" do
        Constants::REQUESTABLE_CURRENT_LOCS.each do |location|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- "))).to be_must_request
        end
      end
      it "should require the list of unavailable current locations to be requested" do
        Constants::UNAVAILABLE_CURRENT_LOCS.each do |location|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- "))).to be_must_request
        end
      end
      it 'should not require location level requests to be requested at the item level' do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- UARCH-30 -|- ON-ORDER -|- "))).to_not be_must_request
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- "))).to       be_must_request
      end
    end
  end
end
