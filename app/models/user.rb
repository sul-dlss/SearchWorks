class User < ActiveRecord::Base
  attr_writer :affiliations, :person_affiliations, :other_attributes

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
      person_affiliation.strip === Settings.EDU_PERSON_AFFILIATION # rubocop:disable Style/CaseEquality
    end
  end

  # user_id and user_email are special keys in honeybadger for aggregating
  # errors
  def to_honeybadger_context
    { user_id: id, user_email: email, affiliations: }
  end
end
