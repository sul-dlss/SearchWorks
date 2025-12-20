# frozen_string_literal: true

module CatalogEmailSending
  extend ActiveSupport::Concern

  # Overrides blacklight to respond with a turbo_stream
  def email
    @documents = action_documents

    if request.post?
      if validate_email_params_and_recaptcha

        send_emails_to_all_recipients(@documents)

        respond_to do |format|
          format.turbo_stream { render 'email_success' }
        end
      else
        # Not valid
        respond_to do |format|
          format.html do
            return render layout: false, status: :unprocessable_content if request.xhr?
            # Otherwise draw the full page
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          return render layout: false if request.xhr?
          # Otherwise draw the full page
        end
      end
    end
  end

  def send_emails_to_all_recipients(documents)
    email_params = { message: params[:message], subject: params[:subject], email_from: params[:email_from] }
    email_addresses.each do |email_address|
      email_params[:to] = email_address
      email = if params[:type] == 'full'
                SearchWorksRecordMailer.full_email_record(documents, email_params, url_options)
              else
                SearchWorksRecordMailer.email_record(documents, email_params, url_options)
              end
      email.deliver_now
    end
  end
end
