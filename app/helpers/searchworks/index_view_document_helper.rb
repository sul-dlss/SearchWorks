module Searchworks::IndexViewDocumentHelper

  def get_main_title(document)
    title = h(document[document_show_link_field.to_s])

    if document['vern_' + document_show_link_field.to_s]
      title = h(document[document_show_link_field]) + " " + h(document['vern_' + document_show_link_field.to_s])
    end
  end

  def get_main_title_date(document)
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

end