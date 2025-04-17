# frozen_string_literal: true

# Users who are Stanford affiliates or on campus are allowed to start a chat
class OnlineChatPolicy
  def initialize(user:)
    @user = user
  end

  # A user who is signed in, on campus, or the VPN should be able to start a chat
  def create?
    @user.on_campus_or_su_affiliated_user?
  end
end
