###
#  Simple controller to handle login and redirect
###
class LoginController < ApplicationController
  def login
    # Set eds_guest to nil so the EDS session gets reset if needed in the article controller
    session['eds_guest'] = nil if session['eds_guest']
    session['suAffiliation'] = request.env['suAffiliation'] || ENV['suAffiliation']
    session['eduPersonAffiliation'] = request.env['eduPersonAffiliation'] || ENV['eduPersonAffiliation']
    session['eduPersonScopedAffiliation'] = request.env['eduPersonScopedAffiliation'] || ENV['eduPersonScopedAffiliation']
    session['unscoped-affiliation'] = request.env['unscoped-affiliation'] || ENV['unscoped-affiliation']
    session['eduPersonEntitlement'] = request.env['eduPersonEntitlement'] || ENV['eduPersonEntitlement']

    if params[:referrer].present?
      redirect_to params[:referrer]
    else
      redirect_back fallback_location: root_url
    end
  end
end
