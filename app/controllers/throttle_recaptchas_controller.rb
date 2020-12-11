# frozen_string_literal: true

class ThrottleRecaptchasController < ApplicationController
  def new; end

  def create
    if verify_recaptcha
      session['throttle_captcha_passed'] = true
      redirect_to params[:redirect_to]
    else
      flash[:error] = 'There was a problem verifying your recaptcha'
      redirect_to new_throttle_recaptcha_path(redirect_to: params[:redirect_to])
    end
  end

  protected

  def check_ua_captcha
    # override to not run the check in this controller
  end
end
