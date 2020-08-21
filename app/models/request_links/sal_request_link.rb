# frozen_string_literal: true

module RequestLinks
  ##
  # This class is intended only to override the available_via_temporary_access? method
  # from the base RequestLink class to enable request links for scannable material that would
  # otherwise be requestable if were not for the temporary access link on the record.
  class SalRequestLink < RequestLink
    ITEM_TYPES = {
      'PAGE-GR' => %w(BUS-STACKS NEWSPAPER NH-INHOUSE STKS STKS-MONO STKS-PERI),
      'default' => %w(BUS-STACKS STKS STKS-MONO STKS-PERI)
    }.freeze
    LIBRARIES = %w(SAL SAL3).freeze
    LOCATIONS = {
      'SAL' => %w(
        EAL-SETS EAL-STKS-C EAL-STKS-J EAL-STKS-K
        FED-DOCS HY-PAGE-EA ND-PAGE-EA PAGE-EA PAGE-GR
        SAL-ARABIC SAL-FOLIO SAL-PAGE SAL-SERG
        SALTURKISH SOUTH-MEZZ STACKS TECH-RPTS
      ),
      'SAL3' => %w(BUS-STACKS PAGE-GR STACKS)
    }.freeze

    private

    def available_via_temporary_access?
      return false if scannable?

      super
    end

    def scannable?
      item_types = ITEM_TYPES[location] || ITEM_TYPES['default']

      LIBRARIES.include?(library) &&
        LOCATIONS[library].include?(location) &&
        items.present? && items.any? do |item|
          item_types.include?(item.type)
        end
    end
  end
end
