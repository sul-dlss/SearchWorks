class Links
  include Enumerable

  def self.ezproxied_hosts
    @ezproxied_hosts ||= {
      'LAW' => Rails.root.join('config/ezproxy/law_proxy_file.txt').read.split("\n"),
      'LANE-MED' => Rails.root.join('config/ezproxy/lane_proxy_file.txt').read.split("\n"),
      default: Rails.root.join('config/ezproxy/sul_proxy_file.txt').read.split("\n")
    }
  end

  def self.ezproxy_url(url, document)
    link_host = begin
      URI.parse(url).host
    rescue StandardError
      nil
    end
    return unless link_host

    libraries = document.holdings.libraries.map(&:code)

    ezproxy_host = if libraries.include?('LAW') && ezproxied_hosts['LAW'].any?(link_host)
                     Settings.libraries.LAW.ezproxy_host
                   elsif libraries.include?('LANE-MED') && ezproxied_hosts['LANE-MED'].any?(link_host)
                     Settings.libraries['LANE-MED'].ezproxy_host
                   elsif ezproxied_hosts[:default].any?(link_host)
                     Settings.libraries.default.ezproxy_host
                   end

    # EZproxy requires the use of the `qurl` param instead of `url` when the value is an encoded URL
    # See: https://help.oclc.org/Library_Management/EZproxy/Troubleshooting/Why_am_I_getting_the_EZproxy_menu_page_when_using_an_encoded_URL_as_the_target_URL
    "#{ezproxy_host}#{{ qurl: url }.to_param}" if ezproxy_host
  end

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
end
