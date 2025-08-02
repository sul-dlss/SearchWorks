# frozen_string_literal: true

class EdsApiPolicy
  def initialize(user:)
    @user = user
  end

  # A user who is signed in, on campus, or the VPN should be able to see articles that are hidden from guests.
  def list_non_guest?
    @user.on_campus_or_su_affiliated_user?
  end

  # A user who is signed in, on campus, or the VPN should be able to read the full text of articles.
  def read_fulltext?
    @user.on_campus_or_su_affiliated_user?
  end
end
