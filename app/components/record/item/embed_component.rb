# frozen_string_literal: true

module Record
  module Item
    class EmbedComponent < ViewComponent::Base
      def initialize(druid:)
        @druid = druid
        super
      end

      attr_reader :druid

      def call
        tag.div(data: { behavior: "purl-embed", embed_url: })
      end

      def embed_url
        "#{Settings.PURL_EMBED_PROVIDER}.json?hide_title=true&url=#{Settings.PURL_EMBED_RESOURCE}#{druid}"
      end
    end
  end
end
