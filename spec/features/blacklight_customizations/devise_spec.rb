require 'rails_helper'

RSpec.describe 'Devise functionality restrictions', type: :routing do
  describe 'registrations' do
    it 'cancel user should not be available' do
      expect(get: '/users/cancel').not_to be_routable
    end
    it 'create user should not be available' do
      expect(post: '/users').not_to be_routable
    end
    it 'new user should not be available' do
      expect(get: '/users/sign_up').not_to be_routable
    end
    it 'edit user should not be available' do
      expect(get: '/users/edit').not_to be_routable
    end
    it 'edit user should not be available' do
      expect(patch: '/users').not_to be_routable
    end
    it 'edit user should not be available' do
      expect(put: '/users').not_to be_routable
    end
    it 'edit user should not be available' do
      expect(delete: '/users').not_to be_routable
    end
  end

  describe 'passwords' do
    it 'user password should not be available' do
      expect(post: '/users/password').not_to be_routable
    end
    it 'new user password should not be available' do
      expect(get: '/users/password/new').not_to be_routable
    end
    it 'edit user password should not be available' do
      expect(get: '/users/password/edit').not_to be_routable
    end
    it 'edit user password should not be available' do
      expect(patch: '/users/password/edit').not_to be_routable
    end
    it 'edit user password should not be available' do
      expect(post: '/users/password/edit').not_to be_routable
    end
  end

  describe 'sessions' do
    it 'new user session should not be available' do
      expect(get: '/users/sign_in').not_to be_routable
    end
    it 'user session should not be available' do
      expect(post: '/users/sign_in').not_to be_routable
    end
    it 'destroy user session should not be available' do
      expect(get: '/users/sign_out').not_to be_routable
    end
  end
end
