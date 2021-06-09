# frozen_string_literal: true

##
# Controller used for feedback forms
class FeedbackFormsController < ApplicationController
  before_action :set_form_type, only: %i[new create]

  def new
  end

  def create
    if request.post?
      if validate
        case @form_type
        when 'connection'
          FeedbackMailer.submit_connection(params, request.remote_ip).deliver_now
          flash[:success] = t('blacklight.connection_form.success')
        else
          FeedbackMailer.submit_feedback(params, request.remote_ip).deliver_now
          flash[:success] = t('blacklight.feedback_form.success')
        end
      end
      respond_to do |format|
        format.json do
          render json: flash
        end
        format.html do
          redirect_to params[:url]
        end
      end
    end
  end

  protected

  def set_form_type
    @form_type = params.permit(:type)[:type] || 'feedback'
  end

  def validate
    errors = []

    errors << 'You must pass the reCAPTCHA challenge' if current_user.blank? && !verify_recaptcha

    if params[:message].nil? or params[:message] == ""
      errors << "A message is required"
    end
    flash[:error] = errors.join("<br/>") unless errors.empty?
    flash[:error].nil?
  end
end
