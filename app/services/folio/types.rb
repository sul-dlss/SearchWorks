module Folio
  class Types
    class << self
      delegate :policies, :circulation_rules, to: :instance
    end

    def self.instance
      @instance ||= new
    end

    attr_reader :cache_dir, :folio_client

    def initialize(cache_dir: Rails.root.join('config/folio'), folio_client: FolioClient.new)
      @cache_dir = cache_dir
      @folio_client = folio_client
    end

    def sync!
      types_of_interest.each do |type|
        file = cache_dir.join("#{type}.json")

        File.write(file, JSON.pretty_generate(folio_client.public_send(type)))
      end
    end

    def circulation_rules
      get_type('circulation_rules').fetch('rulesAsText', '')
    end

    def policies
      @policies ||= {
        request: get_type('request_policies').index_by { |p| p['id'] },
        loan: get_type('loan_policies').index_by { |p| p['id'] },
        overdue: get_type('overdue_fines_policies').index_by { |p| p['id'] },
        lost: get_type('lost_item_fees_policies').index_by { |p| p['id'] },
        notice: get_type('patron_notice_policies').index_by { |p| p['id'] }
      }
    end

    def get_type(type)
      raise "Unknown type #{type}" unless types_of_interest.include?(type)

      file = cache_dir.join("#{type}.json")
      JSON.parse(file.read) if file.exist?
    end

    private

    def types_of_interest
      [
        'request_policies',
        'loan_policies',
        'overdue_fines_policies',
        'lost_item_fees_policies',
        'patron_notice_policies',
        'material_types',
        'loan_types',
        'libraries',
        'locations',
        'circulation_rules'
      ]
    end
  end
end
