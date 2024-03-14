# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  describe '#on_campus_or_su_affiliated_user?' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when there is a current user in the correct affiliation' do
      let(:user) do
        User.new(email: 'user@stanford.edu', affiliations: 'test-stanford:test')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when the user has multiple affiliations' do
      let(:user) do
        User.new(affiliations: 'test-stanford:test; test-stanford:another-test;test-stanford:testing')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when the current user is in the correct person affiliation member group' do
      let(:user) do
        User.new(email: 'user@stanford.edu', affiliations: 'test:noaccess', person_affiliations: 'staff;member', entitlements: '')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when there is a current user with correct entitlement' do
      let(:user) do
        User.new(email: 'user@stanford.edu', affiliations: 'test:noaccess', entitlements: 'stanford:library-eresources-eligible')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be true }
    end

    context 'when the user is not entitled and has no other correct affiliation' do
      let(:user) do
        User.new(affiliations: 'other:other', person_affiliations: 'other', entitlements: '')
      end

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be_falsey }
    end

    context 'when there is a current user not in the correct affilation' do
      let(:user) { User.new }

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be_falsey }
    end

    context 'when there is not a current user' do
      let(:user) { nil }

      it { expect(controller.send(:on_campus_or_su_affiliated_user?)).to be_falsey }
    end
  end
end
