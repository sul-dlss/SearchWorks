# frozen_string_literal: true

##
# A class to handle MARC 008 date logic
class Date008 < MarcField
  attr_reader :range

  def initialize(solr_document, range: nil)
    super(solr_document)
    @range = range
  end

  TYPE_OF_DATE_LABELS = {
    # 'b'
    'c' => { 7..10 => 'Beginning date' },
    'd' => { 7..10 => 'Beginning date', 11..14 => 'Ending date' },
    'e' => { 7..10 => 'Publication date' },
    'i' => { 7..10 => 'Earliest date', 11..14 => 'Latest date' },
    'k' => { 7..10 => 'Earliest date', 11..14 => 'Latest date' },
    'm' => { 7..10 => 'Beginning date', 11..14 => 'Ending date' },
    # 'n'
    'p' => { 7..10 => 'Release date', 11..14 => 'Production date' },
    'q' => { 7..10 => 'Earliest possible date', 11..14 => 'Latest possible date' },
    'r' => { 7..10 => 'Reprint/reissue date', 11..14 => 'Original date' },
    's' => { 7..10 => 'Publication date' },
    't' => { 7..10 => 'Publication date', 11..14 => 'Copyright date' },
    'u' => { 7..10 => 'Beginning date' }
  }.freeze

  def label
    @label ||= TYPE_OF_DATE_LABELS.dig(type_of_date, range) || ('Date' if date1?)
  end

  def values
    @values ||= if marc.blank? || field&.value.blank? || label.blank?
                  []
                else
                  [value].compact
                end
  end

  private

  def date1?
    range == (7..10)
  end

  # MARC 008 isn't repeatable
  def field
    marc['008']
  end

  def tags
    %w[008]
  end

  def type_of_date
    field.value[6]
  end

  def value
    @value ||= begin
      year = field.value[range]

      # suppress wildly approximate dates (e.g. with century precision)
      if /\d{3}[\du-]/.match?(year)
        replacement = date1? ? '0' : '9'
        year.gsub(/[u-]/, replacement)
      end
    end
  end
end
