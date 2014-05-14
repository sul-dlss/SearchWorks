module MarcLinks
  def marc_links
    if self.respond_to?(:to_marc)
      @marc_links ||= MarcLinks::Processor.new(self)
    end
  end
  private
  class Processor
    delegate :present?, to: :all
    def initialize(document)
      @document = document
    end
    def all
      link_fields.map do |link_field|
        link = process_link(link_field)
        OpenStruct.new(
          text: [link[:before], "<a title='#{link[:after]}' href='#{link[:href]}'>#{link[:text]}</a>"].join(' '),
          fulltext?: link_is_fulltext?(link_field),
          stanford_only?: stanford_only?(link)
        )
      end
    end
    def fulltext
      all.select do |link|
        link.fulltext?
      end
    end
    def supplemental
      all.select do |link|
        !link.fulltext?
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
        sub3 = ""
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
          {:before=>"",
           :text=>field["3"],
           :after=>"(source: Casalini)",
           :href=>field["u"],
           :casalini_toc => true
          }
        else
          {:before=>sub3,
           :text=>(suby.blank? ? url_host : suby),
           :after=>subz.join(" "),
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
        [field["3"],field["z"]].each do |subfield|
          return true if !subfield.nil? and subfield.downcase.include?("finding aid")
        end
        return false
      elsif field.indicator2 == "0" or field.indicator2 == "1" or field.indicator2.blank?
        resource_labels.each do |resource_label|
          [field["3"],field["z"]].each do |subfield|
            return false if !subfield.nil? and subfield.downcase.include?(resource_label)
          end
        end
        return true
      else
        # this should catch bad indicators
        return nil
      end
    end

    def stanford_only?(link)
      [link[:before], link[:after]].join.downcase =~ stanford_affiliated_regex
    end

    def stanford_affiliated_regex
      Regexp.new(/available[ -]?to[ -]?stanford[ -]?affiliated[ -]?users[ -]?a?t?[:;.]?/i)
    end
  end
end
