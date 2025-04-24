# frozen_string_literal: true

module Icons
  class SulIconsComponent < Blacklight::Icons::IconComponent
    def classes
      @classes = super
      @classes.push('sul-icon')
    end
  end
end
