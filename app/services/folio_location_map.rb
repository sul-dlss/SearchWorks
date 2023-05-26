# frozen_string_literal: true

require 'csv'

# Similar to https://github.com/sul-dlss/searchworks_traject_indexer/blob/02192452815de3861dcfafb289e1be8e575cb000/lib/locations_map.rb#L18
class FolioLocationMap
  include Singleton
  RENAMES = { 'LANE' => 'LANE-MED' }.freeze

  # @return a tuple of library code and location code
  def self.folio_code_for(library_code:, home_location:)
    library_locations = instance.data.fetch(library_code)
    library_locations[home_location]
  end

  def data
    @data ||= load_map
  end

  def load_map
    CSV.parse(Rails.root.join('lib/translation_maps/locations.tsv').read, col_sep: "\t")
       .each_with_object({}) do |row, result|
      library_code = row[1]
      library_code = RENAMES.fetch(library_code, library_code)

      # SAL3's CDL/ONORDER/INPROCESS locations are all mapped so SAL3-STACKS
      next if row[2] == 'SAL3-STACKS' && row[0] != 'STACKS'

      result[library_code] ||= {}
      result[library_code][row[0]] = row[2]
    end
  end
end
