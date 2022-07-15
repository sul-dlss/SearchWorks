module SearchWorks
  class Links
    include Enumerable

    PROXY_REGEX = /stanford\.idm\.oclc\.org/

    delegate :each, :present?, :blank?, to: :all
    def initialize(links = [])
      @links = links
    end

    def all
      @links || []
    end

    def fulltext
      all.select(&:fulltext?).reject(&:finding_aid?).reject(&:managed_purl?)
    end

    def supplemental
      all.reject(&:fulltext?).reject(&:finding_aid?).reject(&:managed_purl?)
    end

    def finding_aid
      all.select(&:finding_aid?)
    end

    def sfx
      all.select(&:sfx?)
    end

    # sort managed purls by the sort key from the 856$x (with empty values last), then by link text (again with empty values last)
    def managed_purls
      all.select(&:managed_purl?).sort_by { |x| [x.sort.present? ? 0 : 1, x.sort, x.text.present? ? 0 : 1, x.text] }
    end

    def ill
      all.select(&:ill?)
    end

    class Link
      attr_accessor :html, :text, :href, :file_id, :druid, :type, :sort

      def initialize(options = {})
        @html = options[:html]
        @text = options[:text]
        @href = options[:href]
        @fulltext = options[:fulltext]
        @stanford_only = options[:stanford_only]
        @finding_aid = options[:finding_aid]
        @sfx = options[:sfx]
        @managed_purl = options[:managed_purl]
        @file_id = options[:file_id]
        @druid = options[:druid]
        @ill = options[:ill]
        @type = options[:type]
        @sort = options[:sort]
      end

      def ==(other)
        [@html, @fulltext, @stanford_only, @finding_aid, @sfx] == [other.html, other.fulltext?, other.stanford_only?, other.finding_aid?, other.sfx?]
      end

      def fulltext?
        @fulltext
      end

      def stanford_only?
        @stanford_only
      end

      def finding_aid?
        @finding_aid
      end

      def sfx?
        @sfx
      end

      def managed_purl?
        @managed_purl
      end

      def ill?
        @ill
      end
    end
  end
end
