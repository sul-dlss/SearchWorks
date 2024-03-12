# frozen_string_literal: true

###
# Simple concern mixed into classes to return citations
module Citable
  extend ActiveSupport::Concern

  included do
    delegate :citable?, :citations, to: :citation_object
  end

  private

  def citation_object
    @citation_object ||= Citation.new(self)
  end
end
