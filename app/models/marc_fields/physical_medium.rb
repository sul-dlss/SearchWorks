##
# A class to handle MARC 340 field logic
# https://www.loc.gov/marc/bibliographic/bd340.html
class PhysicalMedium < MarcField
  private

  def subfield_delimeter
    '; '
  end

  def tags
    %w[340]
  end
end
