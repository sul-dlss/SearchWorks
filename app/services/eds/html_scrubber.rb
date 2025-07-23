# frozen_string_literal: true

module Eds
  class HtmlScrubber < Rails::HTML::PermitScrubber
    def initialize(**)
      super

      self.tags = %w[p div strong em h1 h2 table thead tr th td tbody ul ol li br]
    end

    def scrub(node)
      node.name = "h1" if node.name == "title" && node.parent.is_a?(Loofah::HTML5::DocumentFragment)
      node.name = "h2" if node.name == "title"
      node.name = "h2" if node.name == "hd"
      node.name = "ol" if node.name == "ref"
      node.name = "li" if node.name == "blist"

      if node.name == "ephtml"
        node.name = "div"

        node.inner_html = CGI.unescapeHTML(node.inner_html)
      end

      super
    end
  end
end
