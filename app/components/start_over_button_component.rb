# frozen_string_literal: true

class StartOverButtonComponent < Blacklight::StartOverButtonComponent
  def call
    link_to(start_over_path, class: 'btn btn-primary btn-reset') do
      tag.span('', class: 'h4 bi bi-skip-backward-fill', aria: { hidden: true }) +
        tag.span(label, class: 'h4 d-none d-sm-inline p-3')
    end
  end

  private

  def label
    'Start over'
  end
end
