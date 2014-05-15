module MarcHelper
  def get_data_with_label_from_marc(marc,label,tag,opts={})
    linking_fields = %W(506 510 514 520 530 538 540 542 545 552 555 561 563 583 590)
    fields = []
    if marc[tag] or (Constants::NIELSEN_TAGS.has_key?(tag) and marc[Constants::NIELSEN_TAGS[tag]])
      label = "Publisher's Summary" if Constants::NIELSEN_TAGS.has_key?(tag) and marc[Constants::NIELSEN_TAGS[tag]] and tag == "520"
      tag = Constants::NIELSEN_TAGS[tag] if Constants::NIELSEN_TAGS.has_key?(tag) and marc[Constants::NIELSEN_TAGS[tag]]
      marc.find_all{|f| (tag) === f.tag}.each do |field|
        field_text = ""
        unless (Constants::HIDE_1ST_IND.include?(tag) and field.indicator1 == "1") or (Constants::HIDE_1ST_IND0.include?(tag) and field.indicator1 == "0")
          if opts[:sub_fields] and opts[:sub_fields].length > 0
            field.each do |sub_field| 
              field_text << "#{sub_field.value} " if opts[:sub_fields].include?(sub_field.code)
            end
          else
            field.each do |sub_field|
              unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
                if tag == "590" and sub_field.code == "c"
                  ckey = sub_field.value[/^(\d+)/]
                  ckey_link = link_to(ckey,url_for(ckey))
                  field_text << "#{sub_field.value.gsub(ckey,ckey_link)} " unless (ckey.nil? or ckey_link.nil?)
                  field_text = field_text.html_safe
                elsif linking_fields.include?(tag) and sub_field.code == "u" and sub_field.value.strip =~ /^https*:\/\//
                  field_text << "#{link_to(sub_field.value, sub_field.value)} "
                  field_text = field_text.html_safe
                elsif sub_field.code == "1" and Constants::NIELSEN_TAGS.has_value?(tag)
                  field_text << "<br/><span class='source'>#{Constants::SOURCES[sub_field.value]}</span>"
                  field_text = field_text.html_safe
                else
                  field_text << "#{sub_field.value} " unless (sub_field.code == 'a' and sub_field.value[0,1] == "%")
                end
              end
            end
          end
          fields << {:field=>field_text, :vernacular=>get_marc_vernacular(marc,field)} unless field_text.blank?
        end
      end
    else
      unmatched_vern = get_unmatched_vernacular(marc,tag)
    end
    return {:label=>label,:fields=>fields,:unmatched_vernacular=>unmatched_vern} unless (fields.empty? and unmatched_vern.nil?)
  end

  def get_marc_vernacular(marc,field)
    return_text = ""
    if field['6']
      field_original = field.tag
      match_original = field['6'].split("-")[1]
      marc.find_all{|f| ('880') === f.tag}.each do |field|
        if field['6'] and field['6'].include?("-")
          field_880 = field['6'].split("-")[0]
          match_880 = field['6'].split("-")[1].gsub("//r","")
          if match_original == match_880 and field_original == field_880
            field.each{ |sub_field| Constants::EXCLUDE_FIELDS.include?(sub_field.code) ? nil : return_text << "#{sub_field.value} "}
          end
        end
      end
    end
    return return_text.strip unless return_text.blank?
  end

  def get_unmatched_vernacular(marc,tag)
    fields = []
    if marc['880']
      marc.find_all{|f| ('880') === f.tag}.each do |field|
        text = ""
        unless field['6'].nil? or !field["6"].include?("-")
          if field['6'].split("-")[1].gsub("//r","") == "00" and field['6'].split("-")[0] == tag
            field.each {|sub_field| Constants::EXCLUDE_FIELDS.include?(sub_field.code) ? nil : text << "#{sub_field.value} "}
          end
        end
        fields << text.strip unless text.blank?
      end
    end
    return fields unless fields.empty?
  end

  def get_unmatched_vernacular_fields(marc,tag)
    fields = []
    if marc['880']
      marc.find_all{|f| ('880') === f.tag}.each do |field|
        unless field['6'].nil? or !field["6"].include?("-")
          if field['6'].split("-")[1].gsub("//r","") == "00" and field['6'].split("-")[0] == tag
            fields << field
          end
        end
      end
    end
    return fields unless fields.blank?
  end

  # Generate dt/dd pair with an unordered list from the table of contents (IE marc 505s)
  def get_toc(marc)
    fields = []
    vern = []
    unmatched_vern = []
    tag = "505"
    if marc[tag] or marc[Constants::NIELSEN_TAGS[tag]]
      if marc[Constants::NIELSEN_TAGS[tag]]
        if marc[tag].nil? or (marc[tag]["t"].nil? and marc[tag]["r"].nil?)
          tag = Constants::NIELSEN_TAGS[tag] if marc[Constants::NIELSEN_TAGS[tag]]
        end
      end
      marc.find_all{|f| (tag) === f.tag}.each do |field|
        text = ""
        field.each do |sub_field| 
          unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
            if sub_field.code == "u" and sub_field.value.strip =~ /^https*:\/\//
              text << "#{link_to(sub_field.value,sub_field.value)} "
            elsif sub_field.code == "1" and Constants::NIELSEN_TAGS.has_value?(tag)
              text << " -|- #{Constants::SOURCES[sub_field.value.strip]}"
            else
              text << "#{sub_field.value} "
            end
          end
        end
        # we could probably just do /\s--\s/ but this works so we'll stick w/ it.
        if Constants::NIELSEN_TAGS.has_value?(tag)
          fields << text.split("-|-").map{|w| w.strip unless w.strip.blank? }.compact
        else
          fields << text.split(/[^\S]--[^\S]/).map{|w| w.strip unless w.strip.blank? }.compact
        end
        vernacular = get_marc_vernacular(marc,field)
        vern << vernacular.split(/[^\S]--[^\S]/).map{|w| w.strip unless w.strip.blank? }.compact unless vernacular.nil?
      end
    end
    
    unmatched_vern_fields = get_unmatched_vernacular(marc,"505")  
    unless unmatched_vern_fields.nil?
      unmatched_vern_fields.each do |vern_field|
        unmatched_vern << vern_field.split(/[^\S]--[^\S]/).map{|w| w.strip unless w.strip.blank? }.compact
      end
    end
    
    new_vern = vern unless vern.empty?
    new_fields = fields unless fields.empty?
    new_unmatched_vern = unmatched_vern unless unmatched_vern.empty?
    return {:label=>"Contents",:fields=>new_fields,:vernacular=>new_vern,:unmatched_vernacular=>new_unmatched_vern} unless (new_fields.nil? and new_vern.nil? and new_unmatched_vern.nil?)
  end

  def render_field_from_marc(fields,opts={})
    render "catalog/field_from_marc", :fields => fields, :options => opts
  end
end