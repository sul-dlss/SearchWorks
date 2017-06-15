##
# A class to parse MARC related works (730 and others) and link them
# to a search. Some subfields are not include in the search
# but they do show up inside the link text, hence the logic in
# the map/join methods.
#
class LinkedRelatedWorks < MarcField
  LINK_CODES = %w[a d f k l m n o p r s t].freeze
  TEXT_CODES = %w[h i x 3].freeze

  def to_partial_path
    'marc_fields/linked_related_works'
  end

  def tags
    %w[700 710 711 720 730]
  end

  # @return [Array<Hash<String>>] output in `:pre_text`, `:link`, `:search`, and `:post_text`
  def values
    relevant_fields.map do |field|
      join_to_view(map_to_sections(field))
    end
  end

  def preprocessors
    super + %i[filter_out_indicator2 filter_out_missing_titles]
  end

  private

  def filter_out_indicator2
    relevant_fields.reject! do |field|
      field.canonical_tag != '730' && field.indicator2 == '2' # are not "included works"
    end
  end

  def filter_out_missing_titles
    relevant_fields.reject! do |field|
      field.canonical_tag != '730' && field.subfields.none? { |subfield| subfield.code == 't' } # do not have a title
    end
  end

  # Divides the subfields into Before, Inside (the link nodes), and After.
  # @return [Hash<Array<Subfield>>] `:before`, `:inside`, and `:after`
  def map_to_sections(field)
    result = {
      before: [],
      inside: [],
      after: []
    }
    all = field.subfields.dup

    # grab before text at top of the list
    all.dup.each do |subfield|
      break if LINK_CODES.include?(subfield.code)
      result[:before] << subfield if TEXT_CODES.include?(subfield.code)
      all.delete(subfield)
    end

    # grab after text from the back of the list
    all.reverse.dup.each do |subfield|
      break if LINK_CODES.include?(subfield.code)
      result[:after] << subfield if TEXT_CODES.include?(subfield.code)
      all.delete(subfield)
    end
    result[:after].reverse! # restore

    # what's left is the link
    result[:inside] = all
    result
  end

  SECTION_TO_VIEW = {
    before: %i[pre_text],
    inside: %i[link search],
    after:  %i[post_text]
  }.freeze

  # Organizes the `map` output into output suitable to render in a view and returned by `values`
  # @return [Hash<String>] output in `:pre_text`, `:link`, `:search`, and `:post_text`
  def join_to_view(subfields)
    result = {}
    SECTION_TO_VIEW.each do |from, destinations|
      destinations.each do |to|
        subfields[from].each do |subfield|
          next if to == :search && TEXT_CODES.include?(subfield.code) # omit text subfields from searches
          result[to] ||= ''
          result[to] << subfield.value.to_s + ' '
        end
      end
    end
    result
  end
end
