# frozen_string_literal: true

class MainTitleDateComponent < ViewComponent::Base
  def initialize(document:)
    @date = document.main_title_date
    super
  end

  attr_accessor :date

  def render?
    date.present?
  end

  def call
    tag.span "[#{date}]", class: "main-title-date"
  end
end
