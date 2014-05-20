class FeedbackFormsController < ApplicationController

  def new
  end

  def create
    if request.post?
      if validate
        RecordMailer.submit_feedback(params, request.remote_ip)
        flash[:success] = t('blacklight.feedback_form.success')
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

  def validate
    errors = []
    if params[:message].nil? or params[:message] == ""
      errors << "A message is required"
    end
    if params[:email_address] and params[:email_address] != ""
      errors << "You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields."
    end
    if params[:message] =~ /.*href=.*|.*url=.*|.*http:\/\/.*|.*https:\/\/.*/i
      errors << "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    flash[:error] = errors.join("<br/>") unless errors.empty?
    flash[:error].nil?
  end
end
