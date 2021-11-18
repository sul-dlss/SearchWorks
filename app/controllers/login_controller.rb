###
#  Simple controller to handle login and redirect
###
class LoginController < ApplicationController
  def login
    if params[:referrer].present?
      redirect_to params[:referrer]
    else
      redirect_back fallback_location: root_url
    end
  end
end
