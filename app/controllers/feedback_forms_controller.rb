# frozen_string_literal: true

##
# Controller used for feedback forms
class FeedbackFormsController < ApplicationController
  def new
  end

  def create
    if request.post?
      if valid?
        FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
        flash.now[:success] = t('blacklight.feedback_form.success')
      end
      respond_to do |format|
        format.json do
          render json: flash
        end
        format.html do
          redirect_to params[:url]
        end
        format.turbo_stream
      end
    end
  end

  protected

  def valid?
    errors = []

    errors << 'You must pass the reCAPTCHA challenge' if current_user.blank? && !verify_recaptcha(action: 'feedback')

    if params[:message].nil? or params[:message] == ""
      errors << "A message is required"
    end
    flash.now[:error] = errors.join("<br/>") unless errors.empty?
    flash.now[:error].nil?
  end
end
