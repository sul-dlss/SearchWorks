module EmailValidation
  extend ActiveSupport::Concern

  def send_emails_to_all_recipients
    email_params = { message: params[:message], subject: params[:subject], email_from: params[:email_from] }
    email_addresses.each do |email_address|
      email_params[:to] = email_address
      email = if params[:type] == 'full'
                SearchWorksRecordMailer.full_email_record(@documents, email_params, url_options)
              else
                SearchWorksRecordMailer.email_record(@documents, email_params, url_options)
              end
      email.deliver_now
    end

    flash[:success] = I18n.t('blacklight.email.success')
  end

  def validate_email_params
    case
    when !%w(full brief).include?(params[:type])
      flash[:error] = I18n.t('blacklight.email.errors.type')
    when params[:email_address].present?
      flash[:error] = I18n.t('blacklight.email.errors.email_address')
    when params[:message] =~ %r{href|url=|https?://}i
      flash[:error] = I18n.t('blacklight.email.errors.message.spam')
    when params[:to].blank?
      flash[:error] = I18n.t('blacklight.email.errors.to.blank')
    when too_many_email_addresses?
      flash[:error] = I18n.t('blacklight.email.errors.to.too_many', max: Settings.EMAIL_THRESHOLD)
    when !valid_email_addresses?
      flash[:error] = I18n.t('blacklight.email.errors.to.invalid', to: params[:to])
    end

    flash[:error].blank?
  end

  def valid_email_addresses?
    email_regexp = defined?(Devise) ? Devise.email_regexp : /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
    email_addresses.all? do |email|
      email.match(email_regexp)
    end
  end

  def too_many_email_addresses?
    email_addresses.length > Settings.EMAIL_THRESHOLD.to_i
  end

  def email_addresses
    params[:to].split(/,|\s+/).reject(&:blank?)
  end

end
