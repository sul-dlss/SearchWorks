module MarcHelper
  def render_if_present(renderable)
    render renderable if renderable.present?
  end

  def link_to_included_works_from_marc(marc)
    contributors_and_works_from_marc(marc)[:included_works]
  end

  def contributors_and_works_from_marc(marc)
    vern_text = ""
    included_works = []
    contributors = []
    ['700', '710', '711', '720'].each do |tag|
      if marc[tag]
        marc.find_all { |f| (tag) === f.tag }.each do |field|
          if !field["t"].blank?
            next unless field.indicator2 == "2"

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
                href_text << subfield.value unless ["e", "i", "j", "4"].include?(subfield.code)
                link_text << subfield.value
              elsif subt == :now or (subt == :passed and subfield.value.strip =~ /[\.|;]$/)
                href_text << subfield.value unless ["e", "i", "j", "4"].include?(subfield.code)
                link_text << subfield.value
                subt = :passed
                subt = :done if subfield.value.strip =~ /[\.|;]$/
              elsif subt == :done
                extra_href << subfield.value unless ["e", "i", "j", "4"].include?(subfield.code)
                extra_text << subfield.value
              else
                href_text << subfield.value unless ["e", "i", "j", "4"].include?(subfield.code)
                link_text << subfield.value
              end
            end
            href = "\"#{href_text.join(" ")}\""
            link = ""
            link << "#{before_text.join(" ")} " unless before_text.blank?
            link << link_to(link_text.join(" "), search_catalog_path(q: href, search_field: 'author_title'))
            link << " #{extra_text.join(" ")}" unless extra_text.blank?
            included_works << link
          else
            link_text = ""
            temp_text = ""
            relator_text = []
            extra_text = ""
            field.each do |subfield|
              next if Constants::EXCLUDE_FIELDS.include?(subfield.code)

              if subfield.code == "e"
                relator_text << subfield.value
              elsif subfield.code == "4" and relator_text.blank?
                relator_text << Constants::RELATOR_TERMS[subfield.value]
              elsif tag == '711' && subfield.code == 'j'
                extra_text << "#{subfield.value} "
              elsif subfield.code != "e" and subfield.code != "4"
                link_text << "#{subfield.value} "
              end
            end
            temp_text << link_to(link_text.strip, search_catalog_path(q: "\"#{link_text}\"", search_field: 'search_author'))
            temp_text << " #{relator_text.join(" ")}" unless relator_text.blank?
            temp_text << " #{extra_text} " unless extra_text.blank?
            vernacular = get_marc_vernacular(marc, field)
            temp_vern = "\"#{vernacular}\""
            temp_text << "<br/>#{link_to h(vernacular), search_catalog_path(q: temp_vern, search_field: 'search_author')}" unless vernacular.nil?
            contributors << temp_text
          end
        end
      else
        if marc['880']
          marc.find_all { |f| ('880') === f.tag }.each do |field|
            if !field['6'].nil? and field['6'].include?("-")
              if field['6'].split("-")[1].gsub("//r", "") == "00" and field['6'].split("-")[0] == tag
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
                  vern_text << link_to(h(link_text.strip), q: "\"#{link_text}\"", action: 'index', search_field: 'author_search')
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
    return_hash[:included_works] = "<dt>Included Work</dt><dd>#{included_works.join('</dd><dd>')}</dd>".html_safe unless included_works.blank?
    return_hash
  end

  def get_marc_vernacular(marc, field)
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
              next if Constants::EXCLUDE_FIELDS.include?(sub.code) || sub.code == '4'

              return_text << sub.value
            end
          end
        end
      end
    end
    return return_text.join(" ") unless return_text.blank?
  end

  def results_imprint_string(document)
    document.fetch(:imprint_display, []).first
  end

  def get_uniform_title(doc)
    return unless doc['uniform_title_display_struct']

    data = doc['uniform_title_display_struct'].first
    field_data = data[:fields].first[:field]

    search_field = if %w(130 730).include?(data[:uniform_title_tag])
                     'search_title'
                   else
                     'author_title'
                   end
    vern = data[:fields].first[:vernacular][:vern]
    href = "\"#{[field_data[:author], field_data[:link_text]].join(' ')}\""
    {
      label: data[:label],
      unmatched_vernacular: data[:unmatched_vernacular],
      fields: [
        {
          field: "#{field_data[:pre_text]} #{link_to(field_data[:link_text], { action: 'index', controller: 'catalog', q: href, search_field: search_field })} #{field_data[:post_text]}".html_safe,
          vernacular: (link_to(vern, { q: "\"#{vern}\"", controller: 'catalog', action: 'index', search_field: search_field }) if vern)
        }
      ]
    }
  end

  def render_field_from_marc(fields, opts = {})
    render "catalog/field_from_marc", fields: fields, options: opts
  end
end
