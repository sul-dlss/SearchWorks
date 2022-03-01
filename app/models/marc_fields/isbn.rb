##
# A class to handle MARC 020 (display everything but subfield c)
# https://www.loc.gov/marc/bibliographic/bd020.html
class Isbn < MarcField
  def values
    return [] if marc.blank?

    @values ||= extracted_fields.flat_map do |_field, subfields|
      subfields.reject { |s| s.code == 'c' }.map(&:value).map(&:strip)
    end.compact
  end

  private

  def tags
    %w[020]
  end
end
