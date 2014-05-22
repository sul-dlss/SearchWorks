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
        SearchWorks::Links::Link.new(
          text: [link[:before], "<a title='#{link[:title]}' href='#{link[:href]}'>#{link[:text]}</a>", "#{'(source: Casalini)' if link[:casalini_toc]}"].compact.join(' '),
          fulltext: link_is_fulltext?(link_field),
          stanford_only: stanford_only?(link),
          finding_aid: link_is_finding_aid?(link_field)
        )
      end
    end
    private
    def link_fields
      @document.to_marc.find_all do |field|
        ('856') === field.tag
      end
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
        if fixed_url.include?("ezproxy.stanford.edu") and fixed_url.include?("url=")
          ezproxy = CGI.parse(URI.parse(fixed_url).query)
          if ezproxy.has_key?("url")
            url_host = URI.parse(ezproxy["url"].first).host
          else
            url_host = url.host
          end
        else
          url_host = url.host
        end
        if field["x"] and field["x"] == "CasaliniTOC"
          {:before=>nil,
           :text=>field["3"],
           :title=>"",
           :href=>field["u"],
           :casalini_toc => true
          }
        else
          {:before=>sub3,
           :text=>(suby.blank? ? url_host : suby),
           :title=>subz.join(" "),
           :href=>field["u"],
           :casalini_toc => false
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
      [link[:before], link[:title]].join.downcase =~ stanford_affiliated_regex
    end

    def stanford_affiliated_regex
      Regexp.new(/available[ -]?to[ -]?stanford[ -]?affiliated[ -]?users[ -]?a?t?[:;.]?/i)
    end
  end
end
