require "spec_helper"

describe Holdings::Requestable do
  describe "#requestable?" do
    describe "item types" do
      it "should not be requestable if the item-type begins with 'NH-'" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new('123 -|- GREEN -|- STACKS -|- -|- NH-SOMETHING'))).not_to be_requestable
      end
      it "should not be requestable if the item type is non-requestable" do
        ["REF", "NONCIRC", "LIBUSEONLY"].each do |type|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- -|- #{type} -|-"))).not_to be_requestable
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
        ).not_to be_requestable
      end
    end

    describe "home locations" do
      it "should not be requestable if the library is GREEN and the home location is MEDIA-MTXT" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new('123 -|- GREEN -|- MEDIA-MTXT -|- -|- -|- '))).not_to be_requestable
      end
    end

    describe 'ON-ORDER items' do
      it 'are not requestable if the library is configured to be noncirc in this case' do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- SPEC-COLL -|- STACKS -|- ON-ORDER -|- STKS-MONO"))).not_to be_requestable
      end
    end
  end

  describe "#show_item_level_request_link?" do
    describe "current locations" do
      it "should require -LOAN current locations to be requested" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SOMETHING-LOAN -|- STKS-MONO"))).to be_show_item_level_request_link
      end
      it "should not require SEE-LOAN current locations to be requested" do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SEE-LOAN -|- STKS-MONO"))).not_to be_show_item_level_request_link
      end
      it "should require the list of request current locations to be requested" do
        Constants::REQUESTABLE_CURRENT_LOCS.each do |location|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- STKS-MONO"))).to be_show_item_level_request_link
        end
      end
      it "should require the list of unavailable current locations to be requested" do
        Constants::UNAVAILABLE_CURRENT_LOCS.each do |location|
          expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- STKS-MONO"))).to be_show_item_level_request_link
        end
      end
      it 'should not require location level requests to be requested at the item level' do
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- SPEC-COLL -|- UARCH-30 -|- ON-ORDER -|- STKS-MONO"))).not_to be_show_item_level_request_link
        expect(Holdings::Requestable.new(Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- STKS-MONO"))).to be_show_item_level_request_link
      end
    end
  end
end
