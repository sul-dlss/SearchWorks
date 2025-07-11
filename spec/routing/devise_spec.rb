# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise functionality restrictions', type: :routing do
  describe 'registrations' do
    it 'cancel user is not available' do
      expect(get: '/users/cancel').not_to be_routable
    end

    it 'create user is not available' do
      expect(post: '/users').not_to be_routable
    end

    it 'new user is not available' do
      expect(get: '/users/sign_up').not_to be_routable
    end

    it 'get edit user is not available' do
      expect(get: '/users/edit').not_to be_routable
    end

    it 'patch edit user is not available' do
      expect(patch: '/users').not_to be_routable
    end

    it 'put edit user is not available' do
      expect(put: '/users').not_to be_routable
    end

    it 'delete edit user is not available' do
      expect(delete: '/users').not_to be_routable
    end
  end

  describe 'passwords' do
    it 'user password is not available' do
      expect(post: '/users/password').not_to be_routable
    end

    it 'new user password is not available' do
      expect(get: '/users/password/new').not_to be_routable
    end

    it 'get edit user password is not available' do
      expect(get: '/users/password/edit').not_to be_routable
    end

    it 'patch edit user password is not available' do
      expect(patch: '/users/password/edit').not_to be_routable
    end

    it 'post edit user password is not available' do
      expect(post: '/users/password/edit').not_to be_routable
    end
  end

  describe 'sessions' do
    it 'get new user session is not available' do
      expect(get: '/users/sign_in').not_to be_routable
    end

    it 'post user session is not available' do
      expect(post: '/users/sign_in').not_to be_routable
    end

    it 'destroy user session is not available' do
      expect(get: '/users/sign_out').not_to be_routable
    end
  end
end
