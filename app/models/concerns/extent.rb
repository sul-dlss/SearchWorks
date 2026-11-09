# frozen_string_literal: true

module Extent
  def extent_sans_format
    [physical_string, characteristics_string].compact.join(' ')
  end

  private

  def physical_string
    return nil unless self[:physical].present?

    [self[:physical]].flatten.join(', ')
  end

  def characteristics_string
    self['characteristics_ssim'].join(' ') if self['characteristics_ssim']
  end
end
