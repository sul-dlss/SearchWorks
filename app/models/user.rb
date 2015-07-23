class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
  attr_accessor :webauth_groups

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # this is a lame workaround so development can proceed:
  #   hardcode webauth_groups if Rails is running in development mode and if
  #   we have set the REMOTE_USER as an ENV value (e.g. at the command line spinning up rails)
  def webauth_groups
    if @webauth_groups.present?
      @webauth_groups
    elsif Rails.env.development? && ENV['REMOTE_USER']
      ["dlss:triannon-searchworks-users"]
    end
  end

  # @return true if current_user is in the appropriate LDAP workgroup; false otherwise
  def can_annotate?
    webauth_groups.include?("dlss:triannon-searchworks-users")
  end

  def sunet
    email.gsub('@stanford.edu', '')
  end
end
