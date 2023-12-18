##
# LinkedSerials deals with the MARC Serial data located in 76x-78x
# and how to link to discover other items in the serial based on subfields
class LinkedSerials < MarcField
  def values
    extracted_fields.map do |field, subfields|
      {
        label: field_label(field),
        values: subfields.map do |subfield|
                  process_subfield(field, subfield)
                end.flatten.compact
      }
    end
  end

  def to_partial_path
    'marc_fields/linked_serials'
  end

  private

  def process_subfield(field, subfield)
    return { text: subfield.value } unless respond_to?(:"#{subfield.code}_subfield", true)

    send(:"#{subfield.code}_subfield", field, subfield.value)
  end

  def a_subfield(field, value)
    if (title = field_title(field)).present?
      { link: "#{value} #{title}", href: "\"#{value} #{title}\"", search_field: 'author_title' }
    else
      { link: value, search_field: 'search' }
    end
  end

  def s_subfield(field, _)
    return if field_has_main_entry?(field)

    { link: field_title(field), href: "\"#{field_title(field)}\"", search_field: 'search_title' }
  end

  # If there is an $s already we need to do nothing here
  # since the peferred title subfield is $s. If there is
  # no $s we want to process $s as if it were $t.
  def t_subfield(field, value)
    return if field['s'].present?

    s_subfield(field, value)
  end

  def x_subfield(_, value)
    [
      { text: '(' },
      { text: 'ISSN' },
      { link: value, search_field: 'isbn_search' },
      { text: ')' }
    ]
  end

  def z_subfield(_, value)
    [
      { text: '(' },
      { link: value, search_field: 'isbn_search' },
      { text: ')' }
    ]
  end

  def field_title(field)
    field['s'] || field['t']
  end

  def field_has_main_entry?(field)
    field['a'].present?
  end

  def field_label(field)
    if merged_with?(field) && field != merged_with_785s.first
      if field == merged_with_785s.last
        'to form'
      else
        'and with'
      end
    else
      FIELD_LABELS[field.canonical_tag][field.indicator2] || FIELD_LABELS[field.canonical_tag]['*']
    end
  end

  def merged_with?(field)
    field.canonical_tag == '785' && field.indicator2 == '7'
  end

  def merged_with_785s
    @merged_with_785s ||= extracted_fields.select { |field, _subfields| merged_with?(field) }.map(&:first)
  end

  def tags
    %w(760 762 765 767 770 772 773 774 775 777 780 785 786 787)
  end

  FIELD_780_LABELS = {
    '0' => 'Continues',
    '1' => 'Continues in part',
    '2' => 'Supersedes',
    '3' => 'Supersedes in part',
    '4' => 'Merged from',
    '5' => 'Absorbed',
    '6' => 'Absorbed in part',
    '7' => 'Separated from'
  }.freeze

  FIELD_785_LABELS = {
    '0' => 'Continued by',
    '1' => 'Continued in part by',
    '2' => 'Superseded by',
    '3' => 'Superseded in part by',
    '4' => 'Absorbed by',
    '5' => 'Absorbed in part by',
    '6' => 'Split into',
    '7' => 'Merged with',
    '8' => 'Changed back to'
  }.freeze

  FIELD_LABELS = {
    '760' => { '*' => 'Main Series' },
    '762' => { '*' => 'Subseries' },
    '765' => { '*' => 'Translation of' },
    '767' => { '*' => 'Translated as' },
    '770' => { '*' => 'Has supplement' },
    '772' => { '*' => 'Supplement to' },
    '773' => { '*' => 'In' },
    '774' => { '*' => 'Constituent unit' },
    '775' => { '*' => 'Other edition' },
    '777' => { '*' => 'Issued with' },
    '780' => FIELD_780_LABELS,
    '785' => FIELD_785_LABELS,
    '786' => { '*' => 'Data source' },
    '787' => { '*' => 'Related item' }
  }.freeze
  private_constant :FIELD_LABELS, :FIELD_780_LABELS, :FIELD_785_LABELS

  def extracted_fields
    @extracted_fields ||= super.to_a
  end
end
