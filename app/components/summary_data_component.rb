# frozen_string_literal: true

class SummaryDataComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  def render?
    render_toc_and_summary? || render_mods_abstract?
  end

  def render_toc_and_summary?
    document.key?(:toc_struct) || document.key?(:summary_struct) || document.respond_to?(:to_marc)
  end

  def render_mods_abstract?
    document.mods_abstract.present?
  end

  def mods_abstract
    safe_join document.mods_abstract.map { |item| sanitize(item) }, '<br />'
  end
end
