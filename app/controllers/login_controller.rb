# frozen_string_literal: true

###
#  Simple controller to handle login and redirect
###
class LoginController < ApplicationController
  def login
    Rails.logger.info "Received login for user: #{current_user&.as_json(methods: :affiliations)}"

    if params[:referrer].present?
      redirect_to params[:referrer]
    else
      redirect_back fallback_location: root_url
    end
  end
end
