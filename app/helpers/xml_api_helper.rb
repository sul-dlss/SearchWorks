# frozen_string_literal: true

module XmlApiHelper
  def drupal_api?
    (params and params.has_key?(:drupal_api) and params[:drupal_api] == "true")
  end

  def get_covers_for_mobile(resp)
    hsh = {}
    if resp.respond_to?(:docs)
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
    [:isbn_display, :oclc, :lccn].select { |n| doc[n] }.each do |number|
      temp_number = doc[number]
      temp_number = [temp_number] unless doc[number].is_a? Array
      temp_number.each do |num|
        nums << "#{number.to_s.gsub('_display', '').upcase}:#{num.delete(' ')}"
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
      numbers.split(",").select { |number| google_response.has_key?(number) and google_response[number].has_key?("thumbnail_url") }.each do |number|
        url_hash[ckey] ||= begin
          cover_url = google_response[number]["thumbnail_url"].gsub("u0026", "&")
          lg_cover_url = cover_url.gsub(/pg=\w+/, "printsec=frontcover").gsub("zoom=5", "zoom=1")
          [cover_url, lg_cover_url]
        end
      end
    end
    url_hash
  end

  def make_call_to_gbs(url)
    # Nasty hack to turn GBS response into a JSON hash
    Net::HTTP.get(URI.parse(url)).gsub("var _GBSBookInfo = ", "").delete_suffix(';')
  end

  def get_authors_for_mobile(doc, ignored_subfields: ['4', '6'])
    doc[:author_person_full_display] ? text = doc[:author_person_full_display].to_a : text = []
    if doc.respond_to?(:to_marc)
      ["700", "710", "711", "720"].select { |num| doc.to_marc[num] }.each do |num|
        doc.to_marc.find_all { |f| (num) === f.tag }.each do |field|
          temp = field.reject { |sf| ignored_subfields.include?(sf.code) }.map(&:value).join(' ')
          text << temp.strip
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

  def get_imprint_for_mobile(marc, subfields: ['a', 'b', 'c'])
    text = []
    if marc["250"] and marc["250"]["a"]
      text << marc["250"]["a"]
    end
    if marc["260"]
      marc.find_all { |f| "260" === f.tag }.each do |field|
        temp = []
        field.each { |sf| subfields.include?(sf.code) ? temp << sf.value : nil }
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
      marc.find_all { |f| f.tag == '880' && f['6']&.include?('-') }.each do |item|
        next unless item['6'].split("-")[1].gsub("//r", "") == "00" and item['6'].split("-")[0] == field

        text = []
        temp = item.reject { |sf| Constants::EXCLUDE_FIELDS.include?(sf.code) }.map(&:value).join(' ')
        text << temp.strip
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
      marc.find_all { |f| f.tag == '880' && f['6']&.include?('-') }.each do |matching_field|
        field_880 = matching_field['6'].split("-")[0]
        match_880 = matching_field['6'].split("-")[1].gsub("//r", "")
        next unless match_original == match_880 and field_original == field_880

        matching_field.select { |sub| Constants::EXCLUDE_FIELDS.exclude?(sub.code) }.each do |sub|
          return_text << sub.value
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
    display_type = document.document_formats
    if display_type
      if display_type.respond_to?(:join)
        display_type.map { |dt| dt.tr("-", " ").parameterize(separator: "_") }.join(" ")
      else
        "#{display_type.tr("-", " ")}".parameterize(separator: "_").to_s
      end
    end
  end
end
