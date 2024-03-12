# frozen_string_literal: true

module ResultsDocumentHelper
  def get_main_title_date(document)
    # MODS data is indexed with the display date in Solr field pub_year_ss
    return "[#{document["pub_year_ss"]}]" if document["pub_year_ss"].present?

    # the code below is for MARC data
    # TODO:  have solrmarc-sw index the date display string into pub_year_ss for MARC data
    publication_year    = document["publication_year_isi"].to_s
    beginning_year      = document["beginning_year_isi"].to_s
    earliest_year       = document["earliest_year_isi"].to_s
    earliest_poss_year  = document["earliest_poss_year_isi"].to_s
    ending_year         = document["ending_year_isi"].to_s
    latest_year         = document["latest_year_isi"].to_s
    latest_poss_year    = document["latest_poss_year_isi"].to_s
    production_year     = document["production_year_isi"].to_s
    original_year       = document["original_year_isi"].to_s
    copyright_year      = document["copyright_year_isi"].to_s
    journal_pub_year    = document['eds_publication_year'].to_s

    # single date
    date = publication_year

    [production_year, original_year, copyright_year].each do |value|
      if !value.empty?
        date = value
        break
      end
    end

    # open-ended/completed date range
    if date.empty? and (!beginning_year.empty? or !ending_year.empty?)
      date = "#{beginning_year} - #{ending_year}"
    end

    # open-ended/completed date range
    if date.empty? and (!earliest_year.empty? or !latest_year.empty?)
      date = "#{earliest_year} - #{latest_year}"
    end

    # "sometime between" date range
    if date.empty? and (!earliest_poss_year.empty? or !latest_poss_year.empty?)
      date = "#{earliest_poss_year} ... #{latest_poss_year}"
    end

    date = journal_pub_year if journal_pub_year.present?

    date = "[#{date}]" unless date.empty?
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
