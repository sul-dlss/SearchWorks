class User < ActiveRecord::Base
  attr_writer :affiliations, :person_affiliations

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

  def sunet
    email.gsub('@stanford.edu', '')
  end

  def affiliations
    @affiliations ||= ENV['suAffiliation']
  end

  def person_affiliations
    @person_affiliations ||= ENV['unscoped-affiliation']
  end

  # If a user has proper Stanford affiliation to allow access to resources now depends
  # on two kinds of affiliation information: the 'su_affiliated' method which returns true
  # if there are specific affiliations recorded in the 'suAffiliation' Shibboleth attribiute
  # as well that which is captured by 'unscoped-affiliation' which is a mapping for 'eduPersonAffiliation'.
  # If the latter returns 'member', we can treat this person as having the correct affiliation status.
  # Refer to https://uit.stanford.edu/service/saml/arp/edupa for more information.
  # Note also that currently 'member' for eduPersonAffiliation has a one to one correspondence
  # with the stanford:library-resources-eligible status.
  def stanford_affiliated?
    su_affiliated? || person_affiliated?
  end

  def su_affiliated?
    return false if affiliations.blank?

    affiliations.split(';').any? do |affiliation|
      Settings.SU_AFFILIATIONS.include?(affiliation.strip)
    end
  end

  def person_affiliated?
    return false if person_affiliations.blank?

    person_affiliations.split(';').any? do |person_affiliation|
      person_affiliation.strip == Settings.UNSCOPED_AFFILIATION
    end
  end

  # user_id and user_email are special keys in honeybadger for aggregating
  # errors
  def to_honeybadger_context
    { user_id: id, user_email: email, affiliations:, person_affiliations: }
  end
end
