require 'spec_helper'

describe 'Devise functionality restrictions', type: :routing do
  describe 'registrations' do
    it 'cancel user should not be available' do
      expect(:get => '/users/cancel').to_not be_routable
    end
    it 'create user should not be available' do
      expect(:post => '/users').to_not be_routable
    end
    it 'new user should not be available' do
      expect(:get => '/users/sign_up').to_not be_routable
    end
    it 'edit user should not be available' do
      expect(:get => '/users/edit').to_not be_routable
    end
    it 'edit user should not be available' do
      expect(:patch => '/users').to_not be_routable
    end
    it 'edit user should not be available' do
      expect(:put => '/users').to_not be_routable
    end
    it 'edit user should not be available' do
      expect(:delete => '/users').to_not be_routable
    end
  end
  describe 'passwords' do
    it 'user password should not be available' do
      expect(:post => '/users/password').to_not be_routable
    end
    it 'new user password should not be available' do
      expect(:get => '/users/password/new').to_not be_routable
    end
    it 'edit user password should not be available' do
      expect(:get => '/users/password/edit').to_not be_routable
    end
    it 'edit user password should not be available' do
      expect(:patch => '/users/password/edit').to_not be_routable
    end
    it 'edit user password should not be available' do
      expect(:post => '/users/password/edit').to_not be_routable
    end
  end
  describe 'sessions' do
    it 'new user session should not be available' do
      expect(:get => '/users/sign_in').to_not be_routable
    end
    it 'user session should not be available' do
      expect(:post => '/users/sign_in').to_not be_routable
    end
    it 'destroy user session should not be available' do
      expect(:get => '/users/sign_out').to_not be_routable
    end
  end
end
