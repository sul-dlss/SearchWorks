# frozen_string_literal: true

class SearchPresenter
  attr_reader :service, :result

  delegate :i18n_key, to: :service
  delegate :name, to: :service, prefix: true
  delegate :see_all_link, :total, to: :result

  def initialize(service, result)
    @service = service
    @result = result
  end

  def no_results?
    total.zero?
  end

  def no_answer?
    @result.nil?
  end
end
