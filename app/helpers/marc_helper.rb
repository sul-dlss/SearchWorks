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
    return_text = []
    if field['6']
      field_original = field.tag
      match_original = field['6'].split("-")[1]
      marc.find_all{|f| ('880') === f.tag}.each do |field|
        if !field['6'].nil? and field['6'].include?("-")
          field_880 = field['6'].split("-")[0]
          match_880 = field['6'].split("-")[1].gsub("//r","")
          if match_original == match_880 and field_original == field_880
            field.each do |sub| 
              if !Constants::EXCLUDE_FIELDS.include?(sub.code)
                return_text << sub.value
              end
            end
          end
        end
      end
    end
    return return_text.join(" ") unless return_text.blank?
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

  # Generate hierarchical structure of subject headings from marc
  def get_subjects(marc)
    text = "<ul>".html_safe
    data = get_subjects_array(marc)
    unless data.blank?
      data.each_with_index do |fields,i|
        text << "<li>".html_safe
        link_text = ""
        title_text = "Search: "
        fields.each do |field|
          link_text << " " unless field == data[i].first
          link_text << field.strip
          #link_text << "\"#{field.strip}\""
          title_text <<  " - " unless field == data[i].first
          title_text << "#{field.strip}"
          text << link_to(field.strip, {:controller => 'catalog', :action => 'index', :q => "\"#{link_text}\"", :search_field => 'subject_terms'}, :title => title_text)
          #text << link_to(field.strip, {:controller => 'catalog', :action => 'index', :q => link_text, :search_field => 'subject_terms'}, :title => title_text)
          text << " &gt; ".html_safe unless field == data[i].last
        end
        text << "</li>".html_safe
      end
    end
    text << "</ul>".html_safe
    return text unless text == "<ul></ul>"
  end
  
  def get_subjects_array(marc)
    subs = ['600','610','611','630','650','651','653','654','655','656','657','658','690','691','693','696', '697','698','699']
    data = []
    marc.find_all{|f| f.tag =~ /^6../}.each do |l|
      if subs.include?(l.tag)
        multi_a = []
        temp_data_array = []
        temp_subs_text = ""
        temp_xyv_array = []
        unless (l.tag == "690" and l['a'] and l['a'].downcase.include?("collection"))
          l.each{|sf| 
            exclude = Constants::EXCLUDE_FIELDS.dup
            ["1","2","3","4","7","9"].each{|i| exclude << i}
            unless exclude.include?(sf.code) 
              if sf.code == "a"
                multi_a << sf.value unless sf.code == "a" and sf.value[0,1] == "%"
              end
              if ["v","x","y","z"].include?(sf.code)
                temp_xyv_array << sf.value
              else
                temp_subs_text << "#{sf.value} " unless (sf.code == "a" or (sf.code == "a" and sf.value[0,1] == "%"))
              end
            end
          }
          if multi_a.length > 1
            multi_a.each do |a|
              data << [a]
            end
          elsif multi_a.length == 1
            str = multi_a.first << " " << temp_subs_text unless (temp_subs_text.blank? and multi_a.empty?)
            temp_data_array << str
          else
            temp_data_array << temp_subs_text unless temp_subs_text.blank?
          end
          temp_data_array.concat(temp_xyv_array) unless temp_xyv_array.empty?
          data << temp_data_array unless temp_data_array.empty?
        end
      end
    end
    return data
  end
  def get_uniform_title(doc,fields,fld=nil)
    # little hack to return nil if the document doesn't have any of the fields
    return nil if fields.map{|f| doc[f] ? true : false }.uniq == [false]
    uniform_title = Object.new
    # take the last of the passed fields
    if fld.nil?
      fields.each do |f|
        uniform_title = doc[f] if doc[f]
      end
    else
      uniform_title = fld
    end
    link_text = []
    extra_text = []
    end_link = false
    uniform_title.each do |sub_field|
      unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
        if !end_link and sub_field.value.strip =~ /[\.|;]$/
          link_text << sub_field.value
          end_link = true
        elsif end_link
          extra_text << sub_field.value
        else
          link_text << sub_field.value
        end
      end
    end
    author = []
    unless fields.include?("730")
      auth_field = doc["100"] || doc["110"] || doc["111"]
      if auth_field
        auth_field.each do |sub_field|
          exclude = Constants::EXCLUDE_FIELDS.dup
          exclude << "e"
          exclude << "4"
          unless exclude.include?(sub_field.code)
            author << sub_field.value
          end
        end
      end
    end
    search_field = ["130", "730"].include?(uniform_title.tag) ? "search_title" : "author_title"
    vern = get_marc_vernacular(doc, uniform_title)
    href = "\"#{[author.join(" "),link_text.join(" ")].join(" ")}\""
    {:label => "Uniform Title:", :fields => [{:field=>"#{link_to(link_text.join(" "),{:action => "index", :controller => "catalog", :q => href, :search_field=>search_field})} #{extra_text.join(" ")}".html_safe, :vernacular => vern ? link_to(vern,{:q => "\"#{vern}\"",:controller=>"catalog",:action=>"index",:search_field=>search_field}) : nil}], :unmatched_vernacular => nil}
  end
  def link_to_author_from_marc(marc, opts={})
    if marc["100"]
      opts[:label] ||= "Author/Creator:"
      opts[:search_options] ||= {:controller => "catalog", :action => 'index', :search_field => 'search_author'}
      link, extra, subs = [],[], []
      marc["100"].each do |sub_field|
        unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
          subs << sub_field.code
          if subs.include?("e") or subs.include?("4")
            extra << sub_field.value
          else
            link << sub_field.value
          end
        end
      end
      vernacular = get_marc_vernacular(marc, marc["100"])
      unless vernacular.blank?
        vernacular = link_to(vernacular, opts[:search_options].merge(:q => "\"#{vernacular}\"")).html_safe
      end
      {:label  => opts[:label],
       :fields => [{:field      => [link_to(link.join(' '), opts[:search_options].merge(:q => "\"#{link.join(' ')}\"")), extra].flatten.compact.join(" ").html_safe,
                    :vernacular => vernacular
                   }]
      }
    end
  end
  def render_field_from_marc(fields,opts={})
    render "catalog/field_from_marc", :fields => fields, :options => opts
  end
end