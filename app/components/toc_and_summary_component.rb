# frozen_string_literal: true

class TocAndSummaryComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  def toc
    @toc ||= document.fetch(:toc_struct, []).first || {}
  end

  def toc_fields
    @toc_fields ||= Array(toc[:fields])
  end

  def toc_vernacular
    @toc_vernacular ||= Array(toc[:vernacular])
  end

  def toc_unmatched_vernacular
    @toc_unmatched_vernacular ||= Array(toc[:unmatched_vernacular])
  end

  def summaries
    @summaries ||= document.fetch(:summary_struct, [])
  end
end
