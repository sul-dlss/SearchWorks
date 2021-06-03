require 'spec_helper'

describe ApplicationController do
  include Devise::Test::ControllerHelpers

  describe '#on_campus_or_su_affiliated_user?' do
    context 'when there is a current user in the correct affiliation' do
      before do
        stub_current_user(context: controller, affiliation: 'test-stanford:test')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when the user has multiple affiliations' do
      before { stub_current_user(context: controller, affiliation: 'test-stanford:test; test-stanford:another-test;test-stanford:testing') }

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
end
