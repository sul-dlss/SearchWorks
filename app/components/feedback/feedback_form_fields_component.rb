# frozen_string_literal: true

module Feedback
  class FeedbackFormFieldsComponent < ViewComponent::Base
    def initialize(form:)
      super
      @form = form
    end
  end
end
