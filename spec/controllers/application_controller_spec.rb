require 'spec_helper'
require 'page_location'

describe ApplicationController do
  include Devise::Test::ControllerHelpers

  describe '#on_campus_or_su_affiliated_user?' do
    context 'when there is a current user in the correct affiliation' do
      before do
        stub_current_user(context: controller, affiliation: 'test-stanford:test')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when there is a current user not in the correct affilation' do
      before { stub_current_user(context: controller) }

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be_falsey }
    end

    context 'when there is not a current user' do
      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be_falsey }
    end
  end

  describe "#page_location" do
    it "should be a SearchWorks::PageLocation" do
      expect(controller.send(:page_location)).to be_a SearchWorks::PageLocation
    end
  end
end
