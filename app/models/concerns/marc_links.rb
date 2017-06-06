module MarcLinks
  def marc_links
    if self.respond_to?(:to_marc)
      @marc_links ||= MarcLinks::Processor.new(self)
    end
  end
  private
  class Processor < SearchWorks::Links
    def initialize(document)
      @document = document
    end
    def all
      link_fields.map do |link_field|
        link = process_link(link_field)
        if link.present?
          SearchWorks::Links::Link.new(
            html: ["<a title='#{link[:title]}' href='#{link[:href]}'>#{link[:text]}</a>", "#{'(source: Casalini)' if link[:casalini_toc]}", " #{link[:additional_text] if link[:additional_text]}"].compact.join(' '),
            text: [link[:text], "#{'(source: Casalini)' if link[:casalini_toc]}", " #{link[:additional_text] if link[:additional_text]}"].compact.join(' ').strip,
            href: link[:href],
            fulltext: link_is_fulltext?(link_field),
            stanford_only: stanford_only?(link),
            finding_aid: link_is_finding_aid?(link_field),
            managed_purl: link_is_managed_purl?(link),
            file_id: file_id(link_field),
            druid: druid(link)
          )
        end
      end.compact
    end

    private

    def link_fields
      @document.to_marc.find_all do |field|
        ('856') === field.tag
      end
    end

    def file_id(link_field)
      return unless link_field['x'].present?
      subxs = link_field.subfields.select do |subfield|
        subfield.code == 'x'
      end

      file_id_value = subxs.find do |subx|
        subx.value.starts_with?('file:')
      end.try(:value)

      file_id_value.gsub('file:', '') if file_id_value.present?
    end

    def process_link(field)
      unless field['u'].nil?
        # Not sure why I need this, but it fails on certain URLs w/o it.  The link printed still has character in it
        fixed_url = field['u'].gsub("^","").strip
        url = URI.parse(fixed_url)
        sub3 = nil
        subz = []
        suby = ""
        field.each{|subfield|
          if subfield.code == "3"
            sub3 = subfield.value
          elsif subfield.code == "z"
            subz << subfield.value
          elsif subfield.code == "y"
            suby = subfield.value
          end
        }
        if fixed_url =~ SearchWorks::Links::PROXY_REGEX && fixed_url.include?("url=")
          proxy = CGI.parse(URI.parse(fixed_url).query)
          if proxy.has_key?("url")
            url_host = URI.parse(proxy["url"].first).host
          else
            url_host = url.host
          end
        else
          url_host = url.host
        end
        if field["x"] and field["x"] == "CasaliniTOC"
          {:text=>field["3"],
           :title=>"",
           :href=>field["u"],
           :casalini_toc => true
          }
        else
          link_text = (!suby.present? && !sub3.present?) ? url_host : [sub3, suby].compact.join(' ')
          title = subz.join(" ")
          additional_text = nil
          if title =~ stanford_affiliated_regex
            additional_text = "<span class='additional-link-text'>#{title.gsub(stanford_affiliated_regex, '')}</span>"
            title = "Available to Stanford-affiliated users only"
          end
          {:text=>link_text,
           :title=> title,
           :href=>field["u"],
           :casalini_toc => false,
           :additional_text => additional_text
          }
        end
      end
      rescue URI::InvalidURIError
        return nil
    end
    def link_is_fulltext?(field)
      resource_labels = ["table of contents", "abstract", "description", "sample text"]
      if field.indicator2 == "2"
        return false
      elsif field.indicator2 == "0" or field.indicator2 == "1" or field.indicator2.blank?
        resource_labels.each do |resource_label|
          return false if "#{field['3']} #{field['z']}".downcase.include?(resource_label)
        end
        return true
      else
        # this should catch bad indicators
        return nil
      end
    end

    def link_is_finding_aid?(field)
      "#{field['3']} #{field['z']}".downcase.include?('finding aid')
    end

    def stanford_only?(link)
      [link[:text], link[:title]].join.downcase =~ stanford_affiliated_regex
    end

    def link_is_managed_purl?(link)
      @document[:managed_purl_urls] && @document[:managed_purl_urls].include?(link[:href])
    end

    def druid(link)
      link[:href].gsub(%r{^https?:\/\/purl.stanford.edu\/?}, '') if link[:href] =~ /purl.stanford.edu/
    end

    def stanford_affiliated_regex
      Regexp.new(/available[ -]?to[ -]?stanford[ -]?affiliated[ -]?users[ -]?a?t?[:;.]?/i)
    end
  end
end
