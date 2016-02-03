module ResultsDocumentHelper

  def get_main_title document
    (document['title_display'] || "").html_safe
  end


  def get_main_title_date document
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
end
