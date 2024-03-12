# frozen_string_literal: true

class TitleRenderingStep < Blacklight::Rendering::AbstractStep
  delegate :sanitize, to: :context

  def render
    next_step(html_safe_value)
  end

  private

  # Support rendering HTML tags used in OSTI article titles with e.g.
  # chemical formulae or mathematical equations.
  def html_safe_value
    sanitize(@values.join(' '), tags: %w[sub sup i em])
  end
end
