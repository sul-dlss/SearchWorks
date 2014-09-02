class SearchWorksRecordMailer < ActionMailer::Base
  default 'Content-Transfer-Encoding' => '7bit'
  include Roadie::Rails::Automatic
  include Blacklight::Configurable
  helper :application, :marc, :record
  def email_record(documents, details, url_gen_params)
    subject = if details[:subject].present?
      details[:subject]
    else
      I18n.t('blacklight.email.text.subject', :count => documents.length, :title => (documents.first.to_semantic_values[:title].first rescue 'N/A') )
    end

    @documents         = documents
    @message           = details[:message]
    @url_gen_params    = url_gen_params
    @blacklight_config = blacklight_config

    mail(:to => details[:to],  :subject => subject)
  end
  def full_email_record(documents, details, url_gen_params)
    subject = if details[:subject].present?
      details[:subject]
    else
      I18n.t('blacklight.email.text.subject', :count => documents.length, :title => (documents.first.to_semantic_values[:title].first rescue 'N/A') )
    end

    @documents         = documents
    @message           = details[:message]
    @url_gen_params    = url_gen_params
    @blacklight_config = blacklight_config

    mail(:to => details[:to],  :subject => subject)
  end

  helper_method :link_to

  private

  def link_to(*args)
    args.first
  end
end
