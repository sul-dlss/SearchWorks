# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequestLink do
  subject(:link) { described_class.new(document: document, library: library, location: location, items: items) }

  let(:document) { SolrDocument.new(id: '12345') }
  let(:library) { 'GREEN' }
  let(:location) { 'LOCKED-STK' }
  let(:items) { [double(type: 'STKS-MONO', current_location: double(code: nil))] }

  describe '#show_location_level_request_link?' do
    context 'for libaries/locations that are configured to have request links' do
      it { expect(link).to be_show_location_level_request_link }
    end

    context 'for libaries that are not configured to have request links' do
      let(:library) { 'CLASSICS' }

      it { expect(link).not_to be_show_location_level_request_link }
    end

    context 'for locations that not configured to have request links' do
      let(:location) { 'IC-NEWSPAPER' }

      it { expect(link).not_to be_show_location_level_request_link }
    end

    context 'when none of the items have a circulating type ' do
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).not_to be_show_location_level_request_link }
    end

    context 'when an item is in a library that wildcards item types' do
      let(:library) { 'SPEC-COLL' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).to be_show_location_level_request_link }
    end

    context 'when an item is in a location that wildcards item types' do
      let(:library) { 'ART' }
      let(:location) { 'ARTLCKL' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).to be_show_location_level_request_link }
    end

    context 'when an item is in a non wildcarded location within a library that specifies location specific item types' do
      let(:library) { 'ART' }
      let(:location) { 'STACKS' }
      let(:items) { [double(type: 'NONCIRC', current_location: double(code: nil))] }

      it { expect(link).not_to be_show_location_level_request_link }
    end

    context 'when a library has its locations wildcarded' do
      let(:library) { '???' }
      let(:location) { 'UNKNOWN-LOCATION' }

      # We don't have this case yet, but here's the test if we ever do
      pending { expect(link).to be_show_location_level_request_link }
    end

    context 'when all items are in a disallowed current location' do
      let(:library) { 'SPEC-COLL' }
      let(:items) { [double(type: 'STKS-MONO', current_location: double(code: 'SPEC-INPRO'))] }

      it { expect(link).not_to be_show_location_level_request_link }
    end
  end

  describe '#render' do
    context 'when not present' do
      let(:location) { 'IC-NEWSPAPER' }

      it { expect(link.render).to eq '' }
    end

    context 'when present' do
      it 'renders the #markup as html_safe' do
        expect(link.render).to match(/<a .*>Request.*<\/a>/)
      end
    end
  end

  describe '#url' do
    it 'appends the request app params to the base URL' do
      expect(link.url).to start_with(Settings.REQUESTS_URL)
      expect(link.url).to include('item_id=12345')
      expect(link.url).to include('origin=GREEN')
      expect(link.url).to include('origin_location=LOCKED-STK')
    end
  end

  describe "#show_item_level_request_link?" do
    def request_link_from_item(item)
      RequestLink.new(document: SolrDocument.new(id: 1234), library: item.library, location: item.home_location, items: [item])
    end

    describe "item types" do
      it "should not be requestable if the item-type begins with 'NH-'" do
        item = Holdings::Callnumber.new('123 -|- GREEN -|- STACKS -|- -|- NH-SOMETHING')
        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER
      end
      it "should not be requestable if the item type is non-requestable" do
        ["REF", "NONCIRC", "LIBUSEONLY"].each do |type|
          item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- -|- #{type} -|-")
          expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER
        end
      end
    end

    describe 'reserves' do
      it 'should not be requestable if the item is on reserve' do
        item = Holdings::Callnumber.new(
          '1234 -|- GREEN -|- STACKS -|- -|- -|- -|- -|- -|- ABC123 -|- -|- -|- -|- course_id -|- reserve_desk -|- loan_period'
        )
        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER
      end
    end

    describe "home locations" do
      it "should not be requestable if the library is GREEN and the home location is MEDIA-MTXT" do
        item = Holdings::Callnumber.new('123 -|- GREEN -|- MEDIA-MTXT -|- -|- -|- ')
        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER
      end
    end

    describe 'ON-ORDER items' do
      it 'are not requestable if the library is configured to be noncirc in this case' do
        item = Holdings::Callnumber.new("123 -|- SPEC-COLL -|- STACKS -|- ON-ORDER -|- STKS-MONO")

        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER
      end
    end

    describe "current locations" do
      it "should require -LOAN current locations to be requested" do
        item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SOMETHING-LOAN -|- STKS-MONO")

        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::ALWAYS
      end
      it "should not require SEE-LOAN current locations to be requested" do
        item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- SEE-LOAN -|- STKS-MONO")

        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::DEPENDS_ON_AVAILABILITY
      end
      it "should require the list of request current locations to be requested" do
        Settings.requestable_current_locations.default.each do |location|
          item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- STKS-MONO")
          expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::ALWAYS
        end
      end
      it "should require the list of unavailable current locations to be requested" do
        Settings.unavailable_current_locations.default.each do |location|
          item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- #{location} -|- STKS-MONO")
          expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::ALWAYS
        end
      end
      it 'should not require location level requests to be requested at the item level' do
        item = Holdings::Callnumber.new("123 -|- SPEC-COLL -|- UARCH-30 -|- ON-ORDER -|- STKS-MONO")
        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::NEVER

        item = Holdings::Callnumber.new("123 -|- GREEN -|- STACKS -|- ON-ORDER -|- STKS-MONO")
        expect(request_link_from_item(item).show_item_level_request_link?(item)).to eq RequestLink::ALWAYS
      end
    end
  end
end
