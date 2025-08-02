# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'searchworks4'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Checks the appropriate policy to determine if a user is allowed to do something.
  def allowed_to?(action, with:)
    with.new(user: current_or_guest_user).public_send(action)
  end
  helper_method :allowed_to?

  private

  def after_sign_out_path_for(*)
    '/Shibboleth.sso/Logout'
  end

  # We want this to run on every request, both for guest users (from devise-guests) and regualar devise users
  def current_or_guest_user
    # used by e.g. sul-bento-app to return results as if it wasn't on-campus.
    return super.without_credentials! if params[:guest]

    super.tap { |user| user.on_campus = on_campus }
  end

  def on_campus
    defined?(@on_campus) or @on_campus = IPRange.includes?(request.remote_ip)
    @on_campus
  end
end
