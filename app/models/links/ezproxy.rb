# frozen_string_literal: true

# Links::Ezproxy decides whether a URL should have a proxy prefix added
#  and which prefix to apply.
class Links
  class Ezproxy
    LANE_RESTRICTED_REGEX = /Access restricted to Stanford community/i

    attr_reader :link, :document

    def initialize(link:, document:)
      @link = link
      @document = document
    end

    def url
      @url ||= link.href.strip
    end

    delegate :link_title, to: :link

    # @return [String, nil] the proxy-prefixed URL or nil if the URL should not be proxied.
    def to_proxied_url
      return unless ezproxy_host

      # EZproxy requires the use of the `qurl` param instead of `url` when the value is an encoded URL
      # See: https://help.oclc.org/Library_Management/EZproxy/Troubleshooting/Why_am_I_getting_the_EZproxy_menu_page_when_using_an_encoded_URL_as_the_target_URL
      "#{ezproxy_host}#{{ qurl: url }.to_param}"
    end

    private

    def ezproxy_host
      if apply_law_proxy_prefix?
        Settings.libraries.LAW.ezproxy_host
      elsif apply_lane_proxy_prefix?
        Settings.libraries['LANE'].ezproxy_host
      elsif apply_sul_proxy_prefix?
        Settings.libraries.default.ezproxy_host
      end
    end

    def apply_law_proxy_prefix?
      libraries.include?('LAW') &&
        ezproxied_hosts['LAW'].any?(link_host)
    end

    def apply_lane_proxy_prefix?
      libraries.include?('LANE') &&
        ezproxied_hosts['LANE'].any?(link_host) &&
        link.stanford_only?
    end

    def apply_sul_proxy_prefix?
      ezproxied_hosts[:default].any?(link_host) &&
        link.stanford_only?
    end

    # Popular database links may not have any associated Solr documents
    def libraries
      @libraries ||= document&.fetch(:holdings_library_code_ssim, []) || []
    end

    def ezproxied_hosts
      @ezproxied_hosts ||= {
        'LAW' => Rails.root.join('config/ezproxy/law_proxy_file.txt').read.split("\n"),
        'LANE' => Rails.root.join('config/ezproxy/lane_proxy_file.txt').read.split("\n"),
        default: Rails.root.join('config/ezproxy/sul_proxy_file.txt').read.split("\n")
      }
    end

    def link_host
      @link_host ||= begin
        URI.parse(url).host
      rescue StandardError
        nil
      end
    end
  end
end
