class NearbyOnShelf
  attr_reader :item_display, :barcode, :before, :after, :page, :search_service

  def initialize(item_display:, barcode:, before: 12, after: 12, page:, search_service:)
    @item_display = Array(item_display)
    @barcode = barcode
    @before = before
    @after = after
    @page = page
    @search_service = search_service
  end

  def document_list
    # De-dup the list of items since duplicate records in the browse view
    # breaks the preview feature and we're pretty sure showing the same
    # record more than once isn't helpful.
    get_nearby_items.uniq { |i| i[:doc]['id'] }.map { |i| SolrDocument.new(i[:doc]) }
  end

  private

  def get_nearby_items
    return [] if item_display_pieces.empty?

    if page == 0
      # get preceding bookspines
      get_preceding_spines_from_field(before) +
        # TODO: can we avoid this extra call to Solr but keep the code this clean?
        # What is the purpose of this call?  To just return the original document?
        get_spines_from_field_values("shelfkey", [shelfkey]) +
        # get following bookspines
        get_following_spines_from_field(after)
    elsif page < 0 # page is negative so we need to get the preceding docs
      get_preceding_spines_from_field((before + 1) * 2, page)
    elsif page > 0 # page is positive, so we need to get the following bookspines
      get_following_spines_from_field(after * 2, page)
    end
  end  # get_nearby_items

  def get_preceding_spines_from_field(how_many, page = 0)
    get_next_spines_from_field(reverse_shelfkey, 'reverse_shelfkey', how_many, page)
  end

  def get_following_spines_from_field(how_many, page = 0)
    get_next_spines_from_field(shelfkey, 'shelfkey', how_many, page)
  end

  # given a shelfkey or reverse shelfkey (for a lopped call number), get the
  #  text for the next "n" nearby items
  def get_next_spines_from_field(starting_value, field_name, how_many, page)
    number_of_items = how_many
    unless page.nil?
      if page < 0
        page = page.to_s[1, page.to_s.length]
      end
      number_of_items = how_many.to_i * page.to_i + 1
    end
    desired_values = get_next_terms_for_field(starting_value, field_name, number_of_items)
    unless page.nil? or page.to_i == 0
      desired_values = desired_values.values_at((desired_values.length - how_many.to_i)..desired_values.length)
    end
    get_spines_from_field_values(field_name, desired_values)
  end

  # return an array of the next terms in the index for the indicated field and
  # starting term. Returned array does NOT include starting term.  Queries Solr (duh).
  def get_next_terms_for_field(starting_term, field_name, how_many = 3)
    result = []
    # terms is array of one element hashes with key=term and value=count
    terms_array = get_next_terms(starting_term, field_name, how_many.to_i + 1)
    terms_array.each { |term_hash|
      result << term_hash.keys[0] unless term_hash.keys[0] == starting_term
    }
    result
  end

  # create an array of sorted html list items containing the appropriate display text
  #  (analogous to what would be visible if you were looking at the spine of
  #  a book on a shelf) from relevant solr docs, given a particular solr
  #  field and value for which to retrieve spine info.
  # Each html list item must match a desired value
  def get_spines_from_field_values(field, desired_values)
    # Get the documents for a set of shelf keys
    response, docs = search_service.search_results do |builder|
      builder.where(field => desired_values.compact)
    end

    spines = docs.flat_map do |doc|
      get_spines_from_doc(doc, field, desired_values.compact)
    end

    spines.uniq { |spine| spine[:sort_key] }.sort_by { |spine| spine[:sort_key] }
  end

  # create a hash with
  #     key = sorting key for the spine,
  #     value = the html list item containing appropriate display text
  #  (analogous to what would be visible if you were looking at the spine of
  #  a book on a shelf) from a solr doc.
  #   spine is:  <li> title [(pub year)] [<br/> author] <br/> callnum </li>
  # Each element of the hash must match a desired value in the
  #   desired_values array for the indicated piece (shelfkey or reverse shelfkey)
  def get_spines_from_doc(doc, field, desired_values)
    return [] if doc[:item_display].nil?

    # This winnows down the holdings hashs on only ones where the desired values includes the shelfkey or reverse shelfkey using a very quick select statment
    # The resulting array looke like [[:"36105123456789",{:barcode=>"36105123456789",:callnumber=>"PS3156 .A53"}]]
    item_array = doc.holdings.callnumbers.select do |callnumber|
      [:shelfkey, :reverse_shelfkey].include?(field.to_sym) && desired_values.include?(callnumber.send(field.to_sym))
    end

    # looping through the resulting temp hash of holdings to build proper sort keys and then return a hash that conains a solr document for every item in the hash
    item_array.map do |callnumber|
      # create sorting key for spine
      # shelfkey asc, then by sorting title asc, then by pub date desc
      # notice that shelfkey and sort_title need to be a constant length
      #  separator of " -|- " is for human readability only
      sort_key = "#{callnumber.shelfkey[0, 100].ljust(100)} -|- "
      sort_key << "#{doc[:title_sort][0, 100].ljust(100)} -|- " unless doc[:title_sort].nil?

      # pub_year must be inverted for descending sort
      if doc[:pub_date].nil? || doc[:pub_date].length == 0
        sort_key << '9999'
      else
        sort_key << doc[:pub_date].tr('0123456789', '9876543210')
      end
      # Adding ckey to sort to make sure we collapse things that have the same callnumber, title, pub date, AND ckey
      sort_key << " -|- #{doc[:id][0, 20].ljust(20)}"
      # We were adding the library to the sortkey. However; if we don't add the library we can easily collapse items that have the same
      # call number (shelfkey), title, pub date, and ckey but are housed in different libraries.
      #sort_key << " -|- #{value[:library][0,40].ljust(40)}"

      { doc: doc.to_h, holding: callnumber, sort_key: sort_key }
    end  # end each item display
  end

  def get_next_terms(curr_value, field, how_many)
    # TermsComponent Query to get the terms
    solr_params = {
      'terms.fl' => field,
      'terms.lower' => curr_value,
      'terms.sort' => 'index',
      'terms.limit' => how_many
    }
    solr_response = Blacklight.default_index.connection.alphaTerms({ params: solr_params })
    # create array of one element hashes with key=term and value=count
    result = []
    terms ||= solr_response['terms'] || []
    if terms.is_a?(Array)
      field_terms ||= terms[1] || []  # solr 1.4 returns array
    else
      field_terms ||= terms[field] || []  # solr 3.5 returns hash
    end
    # field_terms is an array of value, then num hits, then next value, then hits ...
    i = 0
    until result.length == how_many || i >= field_terms.length do
      term_hash = { field_terms[i] => field_terms[i + 1] }
      result << term_hash
      i = i + 2
    end

    result
  end

  def item_display_pieces
    return [] if barcode.blank?

    @item_display_pieces ||= item_display.find { |item_display| item_disp =~ /^#{CGI::escape(barcode)}/ }.presence&.split('-|-') || []
  end

  def shelfkey
    item_display_pieces[6]
  end

  def reverse_shelfkey
    item_display_pieces[7]
  end
end
