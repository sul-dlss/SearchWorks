# frozen_string_literal: true

##
# MarcField class to parse MARC 351s. The MARC spec indicates that the only
# human readable subfields for this particular field are $3, $a, $b, and $c.
class OrganizationAndArrangement < MarcField
  private

  def tags
    ['3513abc']
  end
end
