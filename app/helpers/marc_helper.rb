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

  # Generate dt/dd pair with a link with a label given a marc field
  def link_to_data_with_label_from_marc(marc,label,tag,url,opts={})
    new_fields = []
    new_unmatched_vernacular = []
    fields = get_data_with_label_from_marc(marc,label,tag,opts)
    unless fields.nil? or fields[:fields].nil?
      fields[:fields].each do |field|
        vernacular = link_to(field[:vernacular],url.merge!(:q => "\"#{field[:vernacular]}\"")) unless field[:vernacular].nil?
        new_field = link_to(field[:field].strip, url.merge!(:q => "\"#{field[:field].strip}\"")) unless field[:field].nil?
        new_fields << {:field=>new_field,:vernacular=>vernacular}
      end
      unless fields.nil? or fields[:unmatched_vernacular].nil?
        fields[:unmatched_vernacular].each do |field|
          new_unmatched_vernacular << link_to(field,url.merge!(:q => "\"#{field}\""))
        end
      end
    end
    return {:label=>label,:fields=>new_fields,:unmatched_vernacular=>new_unmatched_vernacular} unless (new_fields.empty? and new_unmatched_vernacular.empty?)
  end

  def link_to_contributor_from_marc(marc)
    contributors_and_works_from_marc(marc)[:contributors]
  end

  def link_to_related_works_from_marc(marc)
    contributors_and_works_from_marc(marc)[:related_works]
  end

  def link_to_included_works_from_marc(marc)
    contributors_and_works_from_marc(marc)[:included_works]
  end

  def contributors_and_works_from_marc(marc)
    vern_text = ""
    related_works = []
    included_works = []
    contributors = []
    ['700', '710', '711', '720', '730'].each do |tag|
      if marc[tag]
        marc.find_all{|f| (tag) === f.tag}.each do |field|
          if tag == "730"
            uniform_title = get_uniform_title(marc,[tag], field)
            uniform_title[:fields].each do |field|
              related_works << field[:field] unless field[:field].nil?
              related_works << field[:vernacular] unless field[:vernacular].nil?
            end
            related_works << uniform_title[:unmatched_vernacular] unless uniform_title[:unmatched_vernacular].nil?
          elsif !field["t"].blank?
            subt = :none
            link_text = []
            extra_text = []
            before_text = []
            href_text = []
            extra_href = []
            field.each do |subfield|
              next if Constants::EXCLUDE_FIELDS.include?(subfield.code)
              # $e $i $4
              if subfield.code == "t"
                subt = :now
              end
              if subfield.code == "i" and subt == :none # assumes $i at beginning
                before_text << subfield.value.gsub(/\s*\(.+\)\s*/, '')
              elsif subt == :none
                href_text << subfield.value unless ["e","i","4"].include?(subfield.code)
                link_text << subfield.value
              elsif subt == :now or (subt == :passed and subfield.value.strip =~ /[\.|;]$/)
                href_text << subfield.value unless ["e","i","4"].include?(subfield.code)
                link_text << subfield.value
                subt = :passed
                subt = :done if subfield.value.strip =~ /[\.|;]$/
              elsif subt == :done
                extra_href << subfield.value unless ["e","i","4"].include?(subfield.code)
                extra_text << subfield.value
              else
                href_text << subfield.value unless ["e","i","4"].include?(subfield.code)
                link_text << subfield.value
              end
            end
            href = "\"#{href_text.join(" ")}\""
            link = ""
            link << "#{before_text.join(" ")} " unless before_text.blank?
            link << link_to(link_text.join(" "), catalog_index_path(q: href, search_field: 'author_title'))
            link << " #{extra_text.join(" ")}" unless extra_text.blank?
            if field.indicator2 == "2"
              included_works << link
            else
              related_works << link
            end
          else
            link_text = ""
            temp_text = ""
            relator_text = []
            field.each do |subfield|
              next if Constants::EXCLUDE_FIELDS.include?(subfield.code)
              if subfield.code == "e"
                relator_text << subfield.value
              elsif subfield.code == "4" and relator_text.blank?
                relator_text << Constants::RELATOR_TERMS[subfield.value]
              elsif subfield.code != "e" and subfield.code != "4"
                link_text << "#{subfield.value} "
              end
            end
            temp_text << link_to(link_text.strip, catalog_index_path(:q => "\"#{link_text}\"", :search_field => 'search_author'))
            temp_text << " #{relator_text.join(" ")}" unless relator_text.blank?
            vernacular = get_marc_vernacular(marc,field)
            temp_vern = "\"#{vernacular}\""
            temp_text << "<br/>#{link_to h(vernacular), catalog_index_path(:q => temp_vern, :search_field => 'search_author')}" unless vernacular.nil?
            contributors << temp_text
          end
        end
      else
        if marc['880']
          marc.find_all{|f| ('880') === f.tag}.each do |field|
            if !field['6'].nil? and field['6'].include?("-")
              if field['6'].split("-")[1].gsub("//r","") == "00" and field['6'].split("-")[0] == tag
                vern_text = "<dt>Contributor</dt><dd>"
                  link_text = ''
                  relator_text = ""
                  field.each do |subfield|
                    if subfield.code == "e"
                      relator_text = Constants::RELATOR_TERMS[subfield.value]
                    elsif subfield.code == "4" and relator_text.blank?
                      relator_text = Constants::RELATOR_TERMS[subfield.value]
                    elsif subfield.code == "6"
                      nil
                    elsif subfield.code != "e" and subfield.code != "4"
                      link_text << "#{subfield.value} "
                    end
                  end
                  vern_text << link_to(h(link_text.strip),:q => "\"#{link_text}\"", :action => 'index', :search_field => 'author_search')
                  vern_text << relator_text unless relator_text.blank?
                  vern_text << "</dd>"
              end
            end
          end
        end
      end
    end
    return_hash = {}
    return_hash[:contributors] = "<dt>Contributor</dt><dd>#{contributors.join('</dd><dd>')}</dd>".html_safe unless contributors.blank?
    return_hash[:contributors] = "#{return_hash[:contributors]} #{vern_text}".html_safe unless vern_text.blank?
    return_hash[:related_works] = "<dt>Related Work</dt><dd>#{related_works.join('</dd><dd>')}</dd>".html_safe unless related_works.blank?
    return_hash[:included_works] = "<dt>Included Work</dt><dd>#{included_works.join('</dd><dd>')}</dd>".html_safe unless included_works.blank?
    return_hash
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
              next if Constants::EXCLUDE_FIELDS.include?(sub.code) || sub.code == '4'
              return_text << sub.value
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
    subs = ['600','610','611','630','650','651','653','654','656','657','658','691','693','696', '697','698','699']
    get_subjects_hierarchy('Subject', get_subjects_array(marc, subs))
  end

  # Generate hierarchical structure of subject headings from marc
  def get_genre_subjects(marc)
    get_subjects_hierarchy('Genre', get_subjects_array(marc, ['655']))
  end

  def get_local_subjects(marc)
    get_subjects_hierarchy('Local subject', get_subjects_array(marc, ['690']))
  end

  def get_subjects_hierarchy(label, subjects)
    text = "<dt>#{label}</dt>".html_safe
    unless subjects.blank?
      subjects.each_with_index do |fields,i|
        text << "<dd>".html_safe
        link_text = ""
        title_text = "Search: "
        fields.each do |field|
          link_text << " " unless field == subjects[i].first
          link_text << field.strip
          title_text <<  " - " unless field == subjects[i].first
          title_text << "#{field.strip}"
          text << link_to(field.strip, catalog_index_path(:q => "\"#{link_text}\"", :search_field => 'subject_terms'), :title => title_text)
          text << " &gt; ".html_safe unless field == subjects[i].last
        end
        text << "</dd>".html_safe
      end
    end
    return text unless text == "<dt>#{label}</dt>"
  end

  def get_subjects_array(marc, subs)
    data = []
    marc.find_all{|f| f.tag =~ /^6../}.each do |l|
      if subs.include?(l.tag)
        multi_a = []
        temp_data_array = []
        temp_subs_text = ""
        temp_xyv_array = []
        l.each do |sf|
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
        end
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
    return data
  end

  def get_related_works_from_marc(marc,label,field)
    if marc[field]
      marc.find_all{|f| (field) === f.tag}.each do |f|
        if f.indicator2 == "2"
          return get_data_with_label_from_marc(marc,"Included Work",field)
        else
          return get_data_with_label_from_marc(marc,label,field)
        end
      end
    end
  end

  def marc_264(marc)
    combined_fields = {}
    normal_fields = marc.find_all{|f| ("264") === f.tag }
    unmatched_vernacular = get_unmatched_vernacular_fields(marc,"264")
    unless normal_fields.blank? and unmatched_vernacular.blank?
      allowed_subfields = %w(3 a b c)
      new_fields = []
      normal_fields.map{|f| new_fields << f} unless normal_fields.blank?
      unmatched_vernacular.map{|f| new_fields << f} unless unmatched_vernacular.blank?
      new_fields.each do |field|
        key = marc_264_labels[:"#{field.indicator1}#{field.indicator2}"]
        combined_fields[key] ||= []
        field_text = []
        field.each do |subfield|
          field_text << subfield.value if allowed_subfields.include?(subfield.code)
        end
        combined_fields[key] << field_text.join(" ")
        vernacular = get_marc_vernacular(marc,field)
        combined_fields[key] << vernacular unless vernacular.blank?
      end
      return combined_fields
    end
    return combined_fields unless combined_fields.blank?
  end

  def marc_264_labels
    {
      :" 0" => "Production",
      :"20" => "Former production",
      :"30" => "Current production",
      :" 1" => "Publication",
      :"21" => "Former publication",
      :"31" => "Current publication",
      :" 2" => "Distribution",
      :"22" => "Former distribution",
      :"32" => "Current distribution",
      :" 3" => "Manufacture",
      :"23" => "Former manufacture",
      :"33" => "Current manufacture",
      :" 4" => "Copyright notice",
      :"24" => "Former copyright",
      :"34" => "Current copyright"
    }
  end

  def results_imprint_string(document)
    if (edition = document.edition).present?
      edition = edition.map do |field|
        field.values.join(' ')
      end.compact.join(' ')
    end
    imprint = document.imprint.values.join(' ') if document.imprint.present?
    if (pub = marc_264(document.to_marc)).present? &&
      copyright_labels = [marc_264_labels[:" 4"], marc_264_labels[:"24"], marc_264_labels[:"34"]]
      pub = pub.map do |label, values|
        unless copyright_labels.include?(label)
          values.join(' ')
        end
      end.compact.join(' ')
    end
    [edition, imprint, pub].compact.join(' - ')
  end

  def get_uniform_title(doc, fields, fld = nil)
    return unless fields.any? { |f| doc[f].present? }
    last_present_tag = fields.reverse.find { |f| doc[f].present? }
    uniform_title = fld || doc[last_present_tag]
    pre_text = []
    link_text = []
    extra_text = []
    end_link = false
    uniform_title.each do |sub_field|
      next if Constants::EXCLUDE_FIELDS.include?(sub_field.code)
      if !end_link && sub_field.value.strip =~ /[\.|;]$/ && sub_field.code != 'h'
        link_text << sub_field.value
        end_link = true
      elsif end_link || sub_field.code == 'h'
        extra_text << sub_field.value
      elsif sub_field.code == 'i' # assumes $i is at beginning
        pre_text << sub_field.value.gsub(/\s*\(.+\)/, '')
      else
        link_text << sub_field.value
      end
    end

    author = []
    unless fields.include?('730')
      auth_field = doc['100'] || doc['110'] || doc['111']
      author = auth_field.map do |sub_field|
        next if (Constants::EXCLUDE_FIELDS + %w(4 e)).include?(sub_field.code)
        sub_field.value
      end.compact if auth_field
    end

    search_field = if %w(130 730).include?(uniform_title.tag)
                     'search_title'
                   else
                     'author_title'
                   end
    vern = get_marc_vernacular(doc, uniform_title)
    href = "\"#{[author.join(' '), link_text.join(' ')].join(' ')}\""
    {
      label: 'Uniform Title',
      unmatched_vernacular: nil,
      fields: [
        {
          field: "#{pre_text.join(' ')} #{link_to(link_text.join(' '), { action: 'index', controller: 'catalog', q: href, search_field: search_field})} #{extra_text.join(' ')}".html_safe,
          vernacular: (link_to(vern, { q: "\"#{vern}\"", controller: 'catalog', action: 'index', search_field: search_field }) if vern)
        }
      ]
    }
  end
  def link_to_author_from_marc(marc, opts={})
    if marc["100"]
      opts[:label] ||= "Author/Creator"
      opts[:search_options] ||= {:controller => "catalog", :action => 'index', :search_field => 'search_author'}
      link, extra, subs = [],[], []
      marc["100"].each do |sub_field|
        unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
          subs << sub_field.code
          case
          when subs.include?('e')
            extra << sub_field.value
          when subs.include?('4')
            extra << Constants::RELATOR_TERMS[sub_field.value] || sub_field.value
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
  def render_field_list_from_marc(fields,opts={})
    render "catalog/field_list_from_marc", :fields => fields, :options => opts
  end
end
