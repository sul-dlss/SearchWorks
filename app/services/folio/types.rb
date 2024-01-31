module Folio
  class Types
    class << self
      delegate :policies, :circulation_rules, :criteria, :locations, :libraries,
               :institutions, :campuses, :service_points, :material_types,
               :cached_location_by_code, :courses, to: :instance
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
      @policies = nil
      @criteria = nil

      types_of_interest.each do |type|
        file = cache_dir.join("#{type}.json")
        data = folio_client.public_send(type).sort_by { |item| item['id'] }
        File.write(file, JSON.pretty_generate(data))
      end

      File.write(cache_dir.join('locations.csv'), Folio::Locations.to_csv)

      circulation_rules = folio_client.circulation_rules
      File.write(cache_dir.join('circulation_rules.txt'), circulation_rules)
      File.write(cache_dir.join('circulation_rules.csv'), Folio::CirculationRules::PolicyService.rules(circulation_rules).map(&:to_csv).join)
    end

    def circulation_rules
      file = cache_dir.join("circulation_rules.txt")
      file.read if file.exist?
    end

    def policies
      @policies ||= {
        request: get_type('request_policies').index_by { |p| p['id'] },
        loan: get_type('loan_policies').index_by { |p| p['id'] },
        overdue: get_type('overdue_fines_policies').index_by { |p| p['id'] },
        'lost-item': get_type('lost_item_fees_policies').index_by { |p| p['id'] },
        notice: get_type('patron_notice_policies').index_by { |p| p['id'] }
      }
    end

    def criteria
      @criteria ||= {
        'group' => get_type('patron_groups').index_by { |p| p['id'] },
        'material-type' => material_types,
        'loan-type' => get_type('loan_types').index_by { |p| p['id'] },
        'location-institution' => get_type('institutions').index_by { |p| p['id'] },
        'location-campus' => get_type('campuses').index_by { |p| p['id'] },
        'location-library' => libraries,
        'location-location' => locations
      }
    end

    def institutions
      @institutions ||= get_type('institutions').index_by { |p| p['id'] }
    end

    def campuses
      @campuses ||= get_type('campuses').index_by { |p| p['id'] }
    end

    def libraries
      @libraries ||= get_type('libraries').index_by { |p| p['id'] }
    end

    def locations
      @locations ||= get_type('locations').index_by { |p| p['id'] }
    end

    def service_points
      @service_points ||= get_type('service_points').index_by { |p| p['id'] }
    end

    def material_types
      @material_types ||= get_type('material_types').index_by { |p| p['id'] }
    end

    def get_type(type)
      raise "Unknown type #{type}" unless types_of_interest.include?(type.to_s)

      file = cache_dir.join("#{type}.json")
      JSON.parse(file.read) if file.exist?
    end

    def cached_location_by_code(code)
      location_data = locations.values.find { |x| x['code'] == code }
      library = libraries[location_data['libraryId']]
      campus = campuses[location_data['campusId']]
      institution = institutions[location_data['institutionId']]

      Folio::Location.from_dynamic(location_data.reverse_merge('library' => library, 'campus' => campus, 'institution' => institution))
    end

    private

    def types_of_interest
      [
        'request_policies',
        'loan_policies',
        'overdue_fines_policies',
        'lost_item_fees_policies',
        'patron_notice_policies',
        'patron_groups',
        'material_types',
        'loan_types',
        'institutions',
        'campuses',
        'libraries',
        'locations',
        'service_points',
        'courses'
      ]
    end
  end
end
