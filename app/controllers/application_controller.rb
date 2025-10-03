# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include BotChallengePage::Controller
  include BotChallengePage::GuardAction
  class_attribute :bot_challenge_config, default: ::BotChallengePage.config

  SESSION_DATETIME_KEY = "t"
  SESSION_FINGERPRINT_KEY = "f"

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'searchworks4'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def after_sign_out_path_for(*)
    '/Shibboleth.sso/Logout'
  end

  def on_campus_or_su_affiliated_user?
    # used by e.g. sul-bento-app to return results as if it wasn't on-campus.
    return false if params[:guest]

    IPRange.includes?(request.remote_ip) || current_user&.stanford_affiliated?
  end
  helper_method :on_campus_or_su_affiliated_user?

  def turnstile_ok?
    return true unless BotChallengePage::BotChallengePageController.bot_challenge_config.enabled

    self.class._bot_detect_passed_good?(request) || current_user || Settings.turnstile.safelist.any? { |cidr| request.remote_ip.in? IPAddr.new(cidr) }
  end
  helper_method :turnstile_ok?
end
