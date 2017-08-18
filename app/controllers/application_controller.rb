class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper

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

  def on_campus_or_su_affiliated_user?
    IPRange.includes?(request.remote_ip) || current_user.present?
  end
  helper_method :on_campus_or_su_affiliated_user?

  def page_location
    SearchWorks::PageLocation.new(params)
  end
end
