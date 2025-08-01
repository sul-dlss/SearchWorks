# frozen_string_literal: true

class BadgeCounterComponent < ViewComponent::Base
  def initialize(count = 0, what = nil, label: nil, classes: %w[badge rounded-pill text-bg-light], additional_classes: [], **kwargs)
    super(**kwargs)

    @count = count
    @what = what
    @label = label
    @classes = classes
    @additional_classes = additional_classes
    @kwargs = kwargs
  end

  def call
    tag.span(label, class: @classes + @additional_classes, **@kwargs)
  end

  def render?
    @count || @label
  end

  def label
    return @label if @label
    return pluralize(number_with_delimiter(@count), @what) if @what

    number_with_delimiter(@count)
  end
end
