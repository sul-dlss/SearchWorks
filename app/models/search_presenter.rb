# frozen_string_literal: true

class SearchPresenter
  delegate :i18n_key, to: :@service
  delegate :see_all_link, :total, :results, to: :@result

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
end
