# frozen_string_literal: true

module ResultsDocumentHelper
  def get_main_title_date(document)
    # Data is indexed with the display date in Solr field pub_year_ss
    date = document["pub_year_ss"] || document['eds_publication_year']
    return if date.blank?

    "[#{date}]"
  end

  def get_book_ids(document)
    isbn = add_prefix_to_elements(Array(document['isbn_display']), 'ISBN')
    oclc = add_prefix_to_elements(Array(document['oclc']), 'OCLC')
    lccn = add_prefix_to_elements(Array(document['lccn']), 'LCCN')

    { 'isbn' => isbn, 'oclc' => oclc, 'lccn' => lccn }
  end

  def add_prefix_to_elements(arr, prefix)
    arr.map do |i|
      "#{prefix}#{i.to_s.gsub(/\W/, '')}"
    end
  end

  def render_struct_field_data(document, field)
    case field
    when Hash
      key = field.keys.first.to_s
      value = field[key]

      case key
      when 'link'
        link_to value, value
      when 'source'
        "<br/><span class='source'>#{value}</span>".html_safe
      else
        Honeybadger.notify("Unexpected struct data field key (#{key}) for #{document.id}")
        value
      end
    when Array
      safe_join(field.map { |x| render_struct_field_data(document, x) }, ' ')
    else
      auto_link(field.to_s)
    end
  end
end
