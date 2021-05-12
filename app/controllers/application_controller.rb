class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'searchworks'

  helper_method :page_location

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def after_sign_out_path_for(*)
    '/Shibboleth.sso/Logout'
  end

  def on_campus_or_su_affiliated_user?
    IPRange.includes?(request.remote_ip) || user_is_stanford_affiliated?
  end
  helper_method :on_campus_or_su_affiliated_user?

  def user_is_stanford_affiliated?
    return unless current_user.present? && session['suAffiliation']

    session['suAffiliation'].split(';').any? do |affiliation|
      Settings.SU_AFFILIATIONS.include?(affiliation.strip)
    end
  end

  def page_location
    SearchWorks::PageLocation.new(params)
  end
end
