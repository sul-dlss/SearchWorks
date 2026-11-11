# frozen_string_literal: true

module Chat
  # Bounds the tool result text sent back to the model, per result and across a turn. SearchWorks
  # tools already return compact, model-oriented text, so this only enforces the budgets.
  class ToolResultBounder
    BUDGET_REACHED_TEXT = 'Evidence budget reached; answer using the evidence already returned.'
    OMITTED_TEXT = '[Additional results omitted to keep the prompt bounded.]'

    def initialize(per_result: Rails.configuration.x.chat.max_tool_result_characters,
                   budget: Rails.configuration.x.chat.max_evidence_characters)
      @per_result = per_result
      @remaining = budget
    end

    def call(result)
      return BUDGET_REACHED_TEXT if @remaining <= 0

      text = result[:text].to_s
      limit = [@per_result, @remaining].min
      text = "#{text.first(limit)}\n#{OMITTED_TEXT}" if text.length > limit
      @remaining -= text.length
      text
    end
  end
end
