# frozen_string_literal: true

class SearchPresenter
  delegate :i18n_key, :see_all_url_template, to: :@service
  delegate :total, :results, to: :@result, allow_nil: true

  def initialize(service, result, query_text)
    @service = service
    @result = result
    @query_text = query_text
  end

  def service_name
    @service.name
  end

  def formatted_total
    return '100+' if service_name == 'lib_guides' && total == 100

    ActiveSupport::NumberHelper.number_to_delimited(total)
  end

  def no_results?
    total.nil? || total.zero?
  end

  def no_answer?
    @result.nil?
  end

  def see_all_link
    format(see_all_url_template, q: CGI.escape(@query_text))
  end
end
