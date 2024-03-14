# frozen_string_literal: true

module EmailValidation
  extend ActiveSupport::Concern

  def validate_email_params
    case
    when %w(full brief).exclude?(params[:type])
      flash[:error] = I18n.t('blacklight.email.errors.type')
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

  def validate_email_params_and_recaptcha
    validate_email_params && verify_recaptcha_if_no_user
  end

  def verify_recaptcha_if_no_user
    return true if current_user.present?

    verify_recaptcha
  end
end
