# frozen_string_literal: true

class SearchPresenter
  delegate :i18n_key, :see_all_url_template, to: :@service
  delegate :total, :results, :q, to: :@result

  def initialize(service, result)
    @service = service
    @result = result
  end

  def service_name
    @service.name
  end

  def no_results?
    total.zero?
  end

  def no_answer?
    @result.nil?
  end

  def see_all_link
    format(see_all_url_template, q: CGI.escape(q))
  end
end
