# frozen_string_literal: true

##
# Simple mixin to add return an Imprint statement from MARC
module MarcImprint
  def imprint
    @imprint ||= Imprint.new(self)
  end
end
