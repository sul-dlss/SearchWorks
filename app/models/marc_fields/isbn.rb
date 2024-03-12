# frozen_string_literal: true

##
# A class to handle MARC 020 (display everything but subfield c)
# https://www.loc.gov/marc/bibliographic/bd020.html
class Isbn < MarcField
  private

  def display_value(field, subfields)
    super(field, subfields.reject { |s| s.code == 'c' })
  end

  def tags
    %w[020]
  end
end
