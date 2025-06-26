# frozen_string_literal: true

module CatalogEmailSending
  extend ActiveSupport::Concern

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

    flash[:success] = I18n.t('blacklight.email.success')
  end
end
