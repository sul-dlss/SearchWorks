# frozen_string_literal: true

class EdsApiPolicy
  def initialize(user:)
    @user = user
  end

  def list_non_guest?
    @user.on_campus_or_su_affiliated_user?
  end

  def read_fulltext?
    @user.on_campus_or_su_affiliated_user?
  end
end
