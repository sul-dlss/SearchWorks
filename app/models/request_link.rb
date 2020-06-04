# frozen_string_literal: true

##
# A model to represent data necessary for rendering a request link
class RequestLink
  attr_reader :document, :library, :location, :items
  def initialize(document:, library:, location:, items: [])
    @document = document
    @library = library
    @location = location
    @items = items
  end

  def present?
    enabled_libraries.include?(library) &&
      in_enabled_location? &&
      not_in_disabled_current_location? &&
      any_items_circulate? &&
      any_items_requestable? && # Will this need to change now? This assumes an item level link, which may temp. be gone
      !available_via_temporary_access?
      # Check for real barcodes?  Only for items that are not on-order?
      # Array of procs / methods to be sent configurable on a library basis.
  end

  def render
    return '' unless present?

    markup.html_safe
  end

  def url
    "#{base_request_url}?#{request_params.to_query}"
  end

  private

  def available_via_temporary_access?
    document&.access_panels&.temporary_access&.present?
  end

  def markup
    "<a href=\"#{url}\" rel=\"nofollow\" data-behavior=\"requests-modal\" class=\"btn btn-default btn-xs request-button\">#{link_text}</a>"
  end

  def base_request_url
    Settings.REQUESTS_URL
  end

  def request_params
    {
      item_id: document[:id],
      origin: library,
      origin_location: location
    }
  end

  def link_text
    library_map = link_text_map[library]

    return link_text_map['default'] unless library_map
    return library_map if library_map.is_a?(String)

    library_map[location] || library_map
  end

  def link_text_map
    {
      'SPEC-COLL' => 'Request on-site access',
      'default' => 'Request'
    }
  end

  def enabled_libraries
    %w[GREEN MEDIA-MTXT SAL SPEC-COLL]
  end

  def in_enabled_location?
    return true if enabled_locations == '*'

    enabled_locations.include?(location)
  end

  def not_in_disabled_current_location?
    items.any? do |item|
      !disabled_current_locations.include?(item.current_location.code)
    end
  end

  def disabled_current_locations
    library_map = disabled_current_locations_map[library]

    library_map || disabled_current_locations_map['default']
  end

  def enabled_locations
    enabled_locations_map[library] || enabled_locations_map['default']
  end

  def any_items_requestable?
    items.any? { |item| !item.must_request? }
  end

  def any_items_circulate?
    return true if circulating_item_types == '*'

    items.any? { |item| circulating_item_types.include?(item.type) }
  end

  def circulating_item_types
    library_map = circulating_item_type_map[library]

    return circulating_item_type_map['default'] unless library_map
    return library_map if library_map.is_a?(Array)

    library_map[location] || library_map
  end

  def circulating_item_type_map
    {
      'GREEN' => %w[GOVSTKS NEWBOOK STKS-MONO STKS-PERI],
      'MEDIA-MTXT' => %w[DVDCD VIDEOGAME EQUIP500 EQUIP250 EQUIP100 EQUIP050 MEDSTKS MEDIA],
      'SAL' => %w[DVDCD PAGE-1DAY NH-MICR STKS-MONO STKS-PERI],
      'SPEC-COLL' => '*',
      'default' => %w[STKS-MONO]
    }
  end

  def disabled_current_locations_map
    {
      'SPEC-COLL' => %w[INPROCESS ON-ORDER SPEC-INPRO],
      'default' => %w[INPROCESS ON-ORDER]
    }
  end

  def enabled_locations_map
    {
      'GREEN' => %w[
        BENDER
        CALIF-DOCS
        FED-DOCS
        FOLIO
        FOLIO-FLAT
        HAS-CA
        HAS-DIGIT
        HAS-FIC
        HAS-NEWBK
        IC-DISPLAY
        INTL-DOCS
        LOCKED-STK
        SSRC-CLASS
        SSRC-CSLI
        SSRC-NEWBK
        STACKS
      ],
      'MEDIA-MTXT' => %w[MM-CDCAB MM-OVERSIZ MM-STACKS],
      'SAL' => %w[
        CHINESE
        EAL-SETS
        EAL-STKS-C
        EAL-STKS-J
        EAL-STKS-K
        FED-DOCS
        FOLIO
        HY-PAGE-EA
        JAPANESE
        KOREAN
        L-PAGE-EA
        LOCK-JPN
        LOCKED-STK
        MEDIA-MTXT
        MICROTEXT
        ND-PAGE-EA
        PAGE-EA
        PAGE-GR
        PAGE-SP
        SAL-ARABIC
        SAL-FOLIO
        SAL-PAGE
        SAL-SERG
        SAL-TEMP
        SALTURKISH
        SHELFBYSER
        SHELFBYTITL
        SOUTH-MEZZ
        STACKS
        TECH-RPTS
      ],
      'SPEC-COLL' => %w[
        BARCHAS
        FELT-STOR
        FELTON
        FELTON-30
        FRECOT
        GOLDSTAR
        GUNST
        GUNST-30
        LOCKED-MAP
        LOCKED-STK
        MANNING
        MANUSCRIPT
        MEDIA-30
        MEDIA-MTXT
        MEDIAX-30
        MSS-10
        MSS-20
        MSS-30
        MSSX-30
        NEWTON
        RARE-BOOKS
        RARE-STOR
        RBC-30
        REFERENCE
        ROBINSON
        SAMSON
        STACKS
        STORAGE
        TAUBE
        THEATRE
        THESES
        U-ARCHIVES
        UARCH-30
        UARCH-REF
        UARCHX-30
      ],
      'default' => %w[STACKS]
    }
  end
end
