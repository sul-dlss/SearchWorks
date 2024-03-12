module XmlApiHelper
  def drupal_api?
    (params and params.has_key?(:drupal_api) and params[:drupal_api] == "true")
  end

  def get_covers_for_mobile(resp)
    hsh = {}
    if resp.respond_to?("docs")
      resp.docs.each do |doc|
        hsh[doc[:id]] = get_standard_nums(doc) unless get_standard_nums(doc).nil?
      end
    else
      hsh[resp[:id]] = get_standard_nums(resp) unless get_standard_nums(resp).nil?
    end
    get_covers_from_response(hsh)
  end

  def get_standard_nums(doc)
    nums = []
    [:isbn_display, :oclc, :lccn].each do |number|
      if doc[number]
        temp_number = doc[number]
        temp_number = [temp_number] unless doc[number].is_a? Array
        temp_number.each do |num|
          nums << "#{number.to_s.gsub('_display', '').upcase}:#{num.gsub(' ', '')}"
        end
      end
    end
    nums.join(",") unless nums.empty?
  end

  def get_covers_from_response(hsh)
    google_url = "https://books.google.com/books?bibkeys=#{hsh.values.compact.join(",")}&jscmd=viewapi"
    string = make_call_to_gbs(google_url)
    #in case of throttled response from GBS
    return {} if string[0, 1] != "{"

    google_response = JSON.parse(string)
    url_hash = {}
    hsh.each do |ckey, numbers|
      numbers.split(",").each do |number|
        if !url_hash.has_key?(ckey) and google_response.has_key?(number) and google_response[number].has_key?("thumbnail_url")
          cover_url = google_response[number]["thumbnail_url"].gsub("u0026", "&")
          lg_cover_url = cover_url.gsub(/pg=\w+/, "printsec=frontcover").gsub("zoom=5", "zoom=1")
          url_hash[ckey] = [cover_url, lg_cover_url]
        end
      end
    end
    url_hash
  end

  def make_call_to_gbs(url)
    # Nasty hack to turn GBS response into a JSON hash
    Net::HTTP.get(URI.parse(url)).gsub("var _GBSBookInfo = ", "").delete_suffix(';')
  end

  def get_authors_for_mobile(doc)
    doc[:author_person_full_display] ? text = doc[:author_person_full_display].to_a : text = []
    if doc.respond_to?(:to_marc)
      ["700", "710", "711", "720"].each do |num|
        if doc.to_marc[num]
          doc.to_marc.find_all { |f| (num) === f.tag }.each do |field|
            temp = ""
            field.each { |sf| ["4", "6"].include?(sf.code) ? nil : temp << "#{sf.value} " }
            text << temp.strip
          end
        end
      end
    end
    return nil if text.empty?

    text
  end

  def get_urls_for_mobile(doc)
    urls = []
    if doc.index_links.present?
      doc.index_links.each do |link|
        urls << { label: link.text, link: link.href }
      end
    end
    (urls.presence)
  end

  def get_imprint_for_mobile(marc)
    text = []
    if marc["250"] and marc["250"]["a"]
      text << marc["250"]["a"]
    end
    if marc["260"]
      marc.find_all { |f| "260" === f.tag }.each do |field|
        temp = []
        field.each { |sf| ["a", "b", "c"].include?(sf.code) ? temp << sf.value : nil }
        text << temp.join(" ")
      end
    end
    return nil if text.empty?

    text.join(" ")
  end

  def get_data_from_marc_for_mobile(marc, field)
    text = []
    if marc[field] or (Constants::NIELSEN_TAGS.has_key?(field) and marc[Constants::NIELSEN_TAGS[field]])
      field = Constants::NIELSEN_TAGS[field] if marc[Constants::NIELSEN_TAGS[field]]
      marc.find_all { |f| (field) === f.tag }.each do |item|
        temp = ""
        vernacular = get_vernacular(marc, item)
        if vernacular.nil?
          item.each do |sf|
            if sf.code == "1" and Constants::NIELSEN_TAGS.has_value?(field)
              temp << Constants::SOURCES[sf.value]
            else
              temp << "#{sf.value} " unless Constants::EXCLUDE_FIELDS.include?(sf.code)
            end
          end
        else
          temp << get_vernacular(marc, item)
        end
        text << temp.strip
      end
    end
    if marc['880']
      marc.find_all { |f| ('880') === f.tag }.each do |item|
        if !item['6'].nil? and item['6'].include?('-')
          if item['6'].split("-")[1].gsub("//r", "") == "00" and item['6'].split("-")[0] == field
            text = []
            temp = ""
            item.each { |sf| Constants::EXCLUDE_FIELDS.include?(sf.code) ? nil : temp << "#{sf.value} " }
            text << temp.strip
          end
        end
      end
    end
    return nil if text.empty?

    text
  end

  def get_vernacular(marc, field)
    return_text = []
    if field['6']
      field_original = field.tag
      match_original = field['6'].split("-")[1]
      marc.find_all { |f| ('880') === f.tag }.each do |field|
        if !field['6'].nil? and field['6'].include?("-")
          field_880 = field['6'].split("-")[0]
          match_880 = field['6'].split("-")[1].gsub("//r", "")
          if match_original == match_880 and field_original == field_880
            field.each do |sub|
              if Constants::EXCLUDE_FIELDS.exclude?(sub.code)
                return_text << sub.value
              end
            end
          end
        end
      end
    end
    return_text.join(" ") if return_text.present?
  end

  def doc_is_a_database?(doc)
    true if document_format_classes(doc) and document_format_classes(doc).include?("database")
  end

  def document_format_classes(document)
    # .to_s is necessary otherwise the default return value is not always a string
    # using "_" as sep. to more closely follow the views file naming conventions
    # parameterize uses "-" as the default sep. which throws errors
    display_type = document[blacklight_config.index.display_type_field]
    if display_type
      if display_type.respond_to?(:join)
        display_type.map { |dt| dt.gsub("-", " ").parameterize(separator: "_") }.join(" ")
      else
        "#{display_type.gsub("-", " ")}".parameterize(separator: "_").to_s
      end
    end
  end
end
