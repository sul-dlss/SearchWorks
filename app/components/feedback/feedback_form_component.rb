# frozen_string_literal: true

module Feedback
  class FeedbackFormComponent < ViewComponent::Base
    # The form is used for both the standalone and the modal. The modal uses the footer component
    def initialize(format: "modal")
      super
      @format = format
    end
  end
end
