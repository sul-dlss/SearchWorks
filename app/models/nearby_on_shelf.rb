class NearbyOnShelf
  attr_reader :type, :options, :search_service

  def initialize(type, config, options, search_service:)
    @type = type
    @blacklight_config = config
    @options = options
    @search_service = search_service
  end

  def blacklight_config
    @blacklight_config
  end

  def items
    # De-dup the list of items since duplicate records in the browse view
    # breaks the preview feature and we're pretty sure showing the same
    # record more than once isn't helpful.
    find_items.uniq { |i| i[:doc]['id'] }
  end

  private

  def logger
    ::Rails.logger
  end

  def params
    {}
  end

  def find_items
    if type == "ajax"
      get_next_spines_from_field(options[:start], options[:field], options[:num], nil)
    else
      get_nearby_items(options[:item_display], options[:preferred_barcode], options[:before], options[:after], options[:page])
    end
  end

  def get_nearby_items(itm_display, barcode, before, after, page)
    items = []
    item_display = get_item_display(itm_display, barcode)

    if !item_display.nil?
      my_shelfkey = get_shelfkey(item_display)
      my_reverse_shelfkey = get_reverse_shelfkey(item_display)

      if page.nil? or page.to_i == 0
        # get preceding bookspines
        items << get_next_spines_from_field(my_reverse_shelfkey, "reverse_shelfkey", before, nil)
        # TODO: can we avoid this extra call to Solr but keep the code this clean?
        # What is the purpose of this call?  To just return the original document?
        items << get_spines_from_field_values([my_shelfkey], "shelfkey").uniq
        # get following bookspines
        items << get_next_spines_from_field(my_shelfkey, "shelfkey", after, nil)
      else
        if page.to_i < 0 # page is negative so we need to get the preceding docs
          items << get_next_spines_from_field(my_reverse_shelfkey, "reverse_shelfkey", (before.to_i + 1) * 2, page.to_i)
        elsif page.to_i > 0 # page is possitive, so we need to get the following bookspines
          items << get_next_spines_from_field(my_shelfkey, "shelfkey", after.to_i * 2, page.to_i)
        end
      end
    end
    items.flatten
  end  # get_nearby_items

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
    get_spines_from_field_values(desired_values, field_name)
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
  def get_spines_from_field_values(desired_values, field)
    spines_hash = {}
      response, docs = search_service.search_results do |builder|
        builder.where(field => desired_values.compact)
      end

      docs.each do |doc|
        hsh = get_spine_hash_from_doc(doc, desired_values.compact, field)
        spines_hash.merge!(hsh)
      end
      result = []
      spines_hash.keys.sort.each { |sortkey|
        result << spines_hash[sortkey]
      }
      result
  end

  # create a hash with
  #     key = sorting key for the spine,
  #     value = the html list item containing appropriate display text
  #  (analogous to what would be visible if you were looking at the spine of
  #  a book on a shelf) from a solr doc.
  #   spine is:  <li> title [(pub year)] [<br/> author] <br/> callnum </li>
  # Each element of the hash must match a desired value in the
  #   desired_values array for the indicated piece (shelfkey or reverse shelfkey)
  def get_spine_hash_from_doc(doc, desired_values, field)
    result_hash = {}
    return if doc[:item_display].nil?

    # This winnows down the holdings hashs on only ones where the desired values includes the shelfkey or reverse shelfkey using a very quick select statment
    # The resulting array looke like [[:"36105123456789",{:barcode=>"36105123456789",:callnumber=>"PS3156 .A53"}]]
    item_array = doc.holdings.callnumbers.select do |callnumber|
      [:shelfkey, :reverse_shelfkey].include?(field.to_sym) && desired_values.include?(callnumber.send(field.to_sym))
    end

    unless item_array.empty?
      # putting items back into a hash for readibility
      # looping through the resulting temp hash of holdings to build proper sort keys and then return a hash that conains a solr document for every item in the hash
      item_array.each do |callnumber|
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

        result_hash[sort_key] = { doc: doc.to_h, holding: callnumber }
      end  # end each item display
    end
    return result_hash
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

  # given a document and the barcode of an item in the document, return the
  #  item_display field corresponding to the barcode, or nil if there is no
  #  such item
  def get_item_display(item_display, barcode)
    item = ""
    if barcode.nil? || barcode.length == 0
      return nil
    end

    [item_display].flatten.each do |item_disp|
      item = item_disp if item_disp =~ /^#{CGI::escape(barcode)}/
    end
    return item unless item == ""
  end

  # return the shelfkey (lopped) piece of the item_display field
  def get_shelfkey(item_display)
    get_item_display_piece(item_display, 6)
  end

  # return the reverse shelfkey (lopped) piece of the item_display field
  def get_reverse_shelfkey(item_display)
    get_item_display_piece(item_display, 7)
  end

  def get_item_display_piece(item_display, index)
    if (item_display)
      item_array = item_display.split('-|-')
      return item_array[index].strip unless item_array[index].nil?
    end
    nil
  end
end
