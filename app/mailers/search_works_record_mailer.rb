# frozen_string_literal: true

###
#  ActionMailer class to send records (full and brief versions) via email
###
class SearchWorksRecordMailer < ApplicationMailer
  default 'Content-Transfer-Encoding' => '7bit'
  include Roadie::Rails::Automatic
  include Blacklight::Configurable
  helper :application, :catalog, :marc, :record, :results_document

  def email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)
    mail(to: details[:to], subject: subject_from_details(details, documents), template_name: [template_prefix, 'email_record'].join)
  end

  def full_email_record(documents, details, url_gen_params)
    setup_email_defaults(documents, details, url_gen_params)
    mail(to: details[:to], subject: subject_from_details(details, documents), template_name: [template_prefix, 'full_email_record'].join)
  end

  helper_method :link_to, :search_catalog_path

  private

  def template_prefix
    'article_' if @documents.first.eds?
  end

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
    details[:subject].presence || I18n.t(
      'blacklight.email.text.subject',
      count: documents.length,
      title: documents.first.to_semantic_values[:title].try(:first) || 'N/A'
    )
  end

  helper_method :blacklight_configuration_context, :document_presenter_class, :render_resource_icon
  ##
  # Context in which to evaluate blacklight configuration conditionals
  def blacklight_configuration_context
    @blacklight_configuration_context ||= Blacklight::Configuration::Context.new(self)
  end

  # override the document presenter to force it to use the ShowDocumentPresenter
  def document_presenter_class(*, **)
    ShowDocumentPresenter
  end

  # disable the resource icon
  def render_resource_icon(*, **); end
end
