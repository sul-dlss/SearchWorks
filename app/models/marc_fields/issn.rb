##
# A class to handle MARC 020a + 020z field logic
# https://www.loc.gov/marc/bibliographic/bd020.html
class Issn < MarcField
  def values
    super.map(&:strip).select { |v| v =~ issn_pattern }
  end

  private

  def tags
    %w[020a 020z]
  end

  def issn_pattern
    /^\d{4}-\d{3}[X\d]\D*$/
  end
end
