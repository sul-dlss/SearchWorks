module SearchWorks
  class Links
    delegate :present?, :first, :last, :each, :map, :select, :find, to: :all
    def initialize(document)
      @document = document
    end
    def all
      []
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
    class Link
      attr_accessor :text
      def initialize(options={})
        @text = options[:text]
        @fulltext = options[:fulltext]
        @stanford_only = options[:stanford_only]
      end
      def ==(other)
        [@text, @fulltext, @stanford_only] == [other.text, other.fulltext?, other.stanford_only?]
      end
      def fulltext?
        @fulltext
      end
      def stanford_only?
        @stanford_only
      end
    end
  end
end
