###
#  ActionMailer class to send records (full and brief versions) via email
###
class SearchWorksRecordMailer < ActionMailer::Base
  default 'Content-Transfer-Encoding' => '7bit'
  include Roadie::Rails::Automatic
  include Blacklight::Configurable
  helper :application, :catalog, :marc, :record, :results_document

  def email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)

    mail(to: details[:to], subject: subject_from_details(details, documents))
  end

  def article_email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)

    mail(to: details[:to], subject: subject_from_details(details, documents))
  end

  def full_email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)

    mail(to: details[:to], subject: subject_from_details(details, documents))
  end

  def article_full_email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)

    mail(to: details[:to], subject: subject_from_details(details, documents))
  end

  helper_method :link_to, :search_catalog_path

  private

  def link_to(*args)
    args.first
  end

  def search_catalog_path(*args); end

  def setup_email_defaults(documents, details, url_gen_params)
    @documents         = documents
    @message           = details[:message]
    @url_gen_params    = url_gen_params
    @blacklight_config = blacklight_config
    @email_from        = details[:email_from]
  end

  def subject_from_details(details, documents)
    if details[:subject].present?
      details[:subject]
    else
      I18n.t(
        'blacklight.email.text.subject',
        count: documents.length,
        title: documents.first.to_semantic_values[:title].try(:first) || 'N/A'
      )
    end
  end
end
