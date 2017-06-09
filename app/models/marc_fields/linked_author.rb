##
# A class to parse MARC "author" fields that have hyperlinks for searching/display
# (i.e., href vs link/anchor) and post text for display (context).
#
# Initially, ported over from solrmarc-sw `author_corp_display`, `author_meeting_display`, and
# based in part on SearchWorks' `link_to_author_from_marc`
#
class LinkedAuthor < MarcField
  TAGS = {
    creator: %w[100],
    corporate_author: %w[110],
    meeting: %w[111]
  }.freeze

  attr_reader :target

  def initialize(document, target)
    @target = target.to_sym
    super(document, TAGS[@target] || [])
  end

  def to_partial_path
    'marc_fields/linked_author'
  end

  def i18n_key
    super + '.' + target.to_s
  end

  def values
    relevant_fields.map do |field|
      field.subfields.each_with_object({}) do |subfield, hash|
        output_for(field, subfield).each do |key|
          hash[key] ||= ''
          hash[key] << "#{subfield.value} "
        end
      end
    end
  end

  private

  # @return [Array<Symbol>] `:link`, `:search`, or `:post_text`
  def output_for(field, subfield)
    keys = []
    keys << :link if linkable?(field, subfield)
    keys << :search if searchable?(field, subfield)
    keys << :post_text if post_text?(field, subfield)
    keys
  end

  def linkable?(_field, subfield)
    case target
    when :creator, :corporate_author
      !%w[e i 4].include?(subfield.code) # exclude 100/110 $e $i $4
    when :meeting
      !%w[j 4].include?(subfield.code) # exclude 111 $j $4
    end
  end

  def searchable?(field, subfield)
    return false unless linkable?(field, subfield) # must first be linkable
    !%w[t].include?(subfield.code) # exclude $t
  end

  def post_text?(field, subfield)
    return true if %w[e 4].include?(subfield.code) # always $e $4
    return false if linkable?(field, subfield) || searchable?(field, subfield) # cannot be linkable or searchable
    !%w[i].include?(subfield.code) # exclude $i
  end
end
