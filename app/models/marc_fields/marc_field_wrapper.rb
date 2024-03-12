# frozen_string_literal: true

##
# This class is intended to wrap Marc::DataFields that come from the marc gem.
# This wrapper class is used to enhance the base Marc::DataField with additional behavior
# such as parsing and retaining encoded data that might otherwise be removed for display (e.g. $6)
# as well as add an attribute writer so subfields can be set as well as read.
class MarcFieldWrapper
  attr_reader :marc_field
  attr_writer :subfields
  delegate :[], :each, :each_with_object, :indicator1, :indicator2, :tag, to: :marc_field

  def initialize(marc_field)
    @marc_field = marc_field
    vernacular_matching_field
  end

  # This method returns the tag for regular fields and
  # the original field tag for vernacular matched fields
  def canonical_tag
    if tag == '880'
      vernacular_matcher_tag
    else
      tag
    end
  end

  def vernacular_matcher_tag
    vernacular_matching_field[/^(\d{3})-(\d{2})/]
    Regexp.last_match(1)
  end

  def vernacular_matcher_iterator
    vernacular_matching_field[/^(\d{3})-(\d{2})/]
    Regexp.last_match(2)
  end

  def vernacular_matcher?
    vernacular_matching_field.include?('-') && if marc_field.tag.start_with?('8')
                                                !vernacular_matching_field.start_with?('8')
                                               else
                                                 vernacular_matching_field.start_with?('8')
                                               end
  end

  def subfields
    @subfields ||= marc_field.subfields
  end

  def ==(other)
    self.equal?(other) || (other.is_a?(MarcFieldWrapper) && self.marc_field == other.marc_field)
  end

  private

  def vernacular_matching_field
    @vernacular_matching_field ||= marc_field['6'] || ''
  end
end
