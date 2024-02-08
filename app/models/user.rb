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

  # Based on previous work and discussions, the 'eduPersonAffiliaton' attribute, which is mapped
  # to the 'unscoped-affiliation' attribute, should have sufficient information to decide whether
  # or not a user has the right affiliation access.  If the value of this attribute is
  # 'member', we should provide access. To be on the safe side, we are still including
  # a check against suAffiliation in case 'eduPersonAffiliation' does not provide affiliation access.
  # If this situation occurs, we want to log the issue.
  # Refer to https://uit.stanford.edu/service/saml/arp/edupa for more information.
  # Note also that currently 'member' for eduPersonAffiliation has a one to one correspondence
  # with the stanford:library-resources-eligible status.
  def stanford_affiliated?
    # Will rely primarily on eduPersonAffiliation so return true if this works
    return true if person_affiliated?

    # If not true, we still want to check against suAffiliation.
    # We also want to send a notification in case it is covered by suAffiliation
    # because this shows us a mismatch between the two attributes when there shouldn't be a difference.
    if su_affiliated?
      Honeybadger.notify("User affiliations and privileges: Not affiliated by eduPersonAffiliation: #{person_affiliations}; " \
                         "Affiliated by suAffiliation: #{affiliations}", context: to_honeybadger_context)
      true
    end
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
