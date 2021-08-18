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

  def self.for(document:, library:, location:, items: [])
    RequestLinkFactory.for(
      library: library, location: location
    ).new(document: document, library: library, location: location, items: items)
  end

  def present?
    enabled_libraries.include?(library) &&
      in_enabled_location? &&
      not_in_disabled_current_location? &&
      any_items_circulate? &&
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

  def classes
    'btn btn-default btn-xs request-button'
  end

  def markup
    "<a href=\"#{url}\" rel=\"nofollow\" target=\"_blank\" title=\"Opens in new tab\" class=\"#{classes}\">#{link_text} <span class=\"sr-only\">(opens in new tab)</span></a>"
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
    %w[ARS ART BUSINESS EARTH-SCI EAST-ASIA EDUCATION ENG GREEN LAW MEDIA-MTXT MUSIC RUMSEYMAP SAL SAL3 SCIENCE SPEC-COLL TANNER]
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

  def any_items_circulate?
    return true if circulating_item_types == '*'

    items.any? { |item| circulating_item_types.include?(item.type) }
  end

  def circulating_item_types
    library_map = circulating_item_type_map[library]

    return circulating_item_type_map['default'] unless library_map
    return library_map if library_map.is_a?(Array)

    library_map[location] || library_map['default'] || library_map
  end

  def circulating_item_type_map
    {
      'ARS' => %w[STKS],
      'ART' => {
        'ARTLCKL' => '*',
        'ARTLCKL-R' => '*',
        'ARTLCKM' => '*',
        'ARTLCKM-R' => '*',
        'ARTLCKO' => '*',
        'ARTLCKO-R' => '*',
        'ARTLCKS' => '*',
        'ARTLCKS-R' => '*',
        'default' => %w[STKS-MONO STKS-PERI REF MEDIA]
      },
      'BUSINESS' => %w[STKS AUDIO CAREERCOLL POP-COLL NH-DVDCD NH-PERI],
      'EARTH-SCI' => %w[ATLAS EASTK-DOC LCKSTK MEDIA POP-COLL STKS THESIS THESIS-EXP],
      'EAST-ASIA' => %w[STKS-MONO STKS-PERI NH-DVDCD],
      'EDUCATION' => %w[KIT MEDIA NH-MICR NH-PERMRES NH-PERMRS2 NH-PERMRS7 NH-7DAY STKS-MONO STKS-PERI LCKSTK],
      'ENG' => %w[STKS PERI],
      'GREEN' => %w[GOVSTKS NEWBOOK STKS-MONO STKS-PERI],
      'LAW' => %w[LAW-STKS LAW-NEW LAW-PERBND NH-7DAY LAPTOP],
      'MEDIA-MTXT' => %w[DVDCD VIDEOGAME EQUIP500 EQUIP250 EQUIP100 EQUIP050 MEDSTKS MEDIA],
      'MUSIC' => %w[DVDCD SCORE STKS],
      'RUMSEYMAP' => '*',
      'SAL' => {
        'SAL-TEMP' => %w[NONCIRC],
        'UNCAT' => %w[NONCIRC],
        'default' => %w[ARCHIVE EASTK-DOC GOVSTKS NEWSPAPER NH-INHOUSE NH-MICR PAGE-1DAY PERI PERIBND PERIUNBND STKS-MONO STKS-PERI STKS2 THESIS]
      },
      'SAL3' => %w[ATLAS DVDCD EASTK-DOC GOVSTKS INDEX MEDIA NEWSPAPER NH-7DAY NH-DVDCD NH-INHOUSE NH-RECORDNG PERI2 PERIBND REF SCORE STKS STKS-MONO STKS-PERI],
      'SCIENCE' => %w[STKS PERI MEDIA],
      'SPEC-COLL' => '*',
      'TANNER' => %w[STKS],
      'default' => %w[STKS-MONO]
    }
  end

  def disabled_current_locations_map
    {
      'SPEC-COLL' => %w[INPROCESS MISSING ON-ORDER SPEC-INPRO],
      'default' => %w[]
    }
  end

  def enabled_locations_map
    {
      'ART' => %w[
        ARTLCKL
        ARTLCKL-R
        ARTLCKM
        ARTLCKM-R
        ARTLCKO
        ARTLCKO-R
        ARTLCKS
        ARTLCKS-R
        FOLIO
        INPROCESS
        MEDIA
        ON-ORDER
        REF-FOLIO
        REFERENCE
        STACKS
      ],
      'BUSINESS' => %w[
        BUS-CMC
        BUS-PER
        BUS-TEMP
        INPROCESS
        MEDIA
        ON-ORDER
        PAGE-IRON
        STACKS
      ],
      'EARTH-SCI' => %w[
        ATCIRCDESK
        INPROCESS
        MAP-CASES
        MAP-FILE
        MEZZANINE
        ON-ORDER
        STACKS
        STORAGE
        TECH-RPTS
        THESES
      ],
      'EAST-ASIA' => %w[
        CHINESE
        EAL-SETS
        EAL-STKS-C
        EAL-STKS-J
        EAL-STKS-K
        FOLIO
        FOLIO-CHN
        FOLIO-FLAT
        FOLIO-JPN
        FOLIO-KOR
        HY-PAGE-EA
        INPROCESS
        JAPANESE
        KOREAN
        L-PAGE-EA
        MEDIA
        MICROTEXT
        ND-PAGE-EA
        ON-ORDER
        SETS
        STACKS
      ],
      'EDUCATION' => %w[
        CURRICULUM
        CURRSTOR
        INPROCESS
        LOCKED-STK
        MICROTEXT
        ON-ORDER
        PERM-RES
        STACKS
        STORAGE
      ],
      'ENG' => %w[
        INPROCESS
        ON-ORDER
        SERIALS
        SHELBYSER
        STACKS
        TECH-RPTS
      ],
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
        IC
        IC-DISPLAY
        INPROCESS
        INTL-DOCS
        LOCKED-STK
        ON-ORDER
        SSRC
        SSRC-CLASS
        SSRC-CSLI
        SSRC-NEWBK
        STACKS
      ],
      'LAW' => %w[
        BASEMENT
        FOLIO-BAS
        LAW-CAREER
        LOCKED-STK
        NEWBOOKS
        OUT-TRAVEL
        PERM-RES
        STACKS-1
        VROOMAN
        VROOMAN-OV
        WELLNESS
      ],
      'MEDIA-MTXT' => %w[INPROCESS MM-CDCAB MM-OVERSIZ MM-STACKS ON-ORDER],
      'MUSIC' => %w[FOLIO FOLIO-FLAT INPROCESS MINIATURE ON-ORDER RECORDINGS SCORES STACKS],
      'RUMSEYMAP' => %w[
        FOLIO
        INPROCESS
        MAP-CASES
        MAP-FILE
        MAPCASES-S
        MEZZ-STOR
        MEZZANINE
        MP-CASE-LG
        MP-CASE-MD
        MP-CASE-SM
        ON-ORDER
        PAGE-RM
        REFERENCE
        RUMSEY
        RUMSEYREF
        RUMXEMPLAR
        STACKS
        STK-GEMS
        STK-LG
        STK-MED
        STK-SM
        STK-XLG
        W7-ATLASES
        W7-BXLG-HM
        W7-BXSM-HM
        W7-CASE-HM
        W7-CASE-MD
        W7-CASE-MT
        W7-FOLIO
        W7-FRAME
        W7-M-CASES
        W7-MAP-BXL
        W7-MAP-BXS
        W7-MAP-XLG
        W7-OBJECTS
        W7-POCK-LG
        W7-POCK-RG
        W7-POCKET
        W7-REF
        W7-ROLLED
        W7-SANBORN
        W7-STAFF
        W7-STK-LG
        W7-STK-MED
        W7-STK-SM
        W7-STK-XLG
        W7-STKS
      ],
      'SAL' => %w[
        CHINESE
        EAL-SETS
        EAL-STKS-C
        EAL-STKS-J
        EAL-STKS-K
        FED-DOCS
        FOLIO
        HY-PAGE-EA
        INPROCESS
        JAPANESE
        KOREAN
        L-PAGE-EA
        MEDIA-MTXT
        ND-PAGE-EA
        ON-ORDER
        PAGE-EA
        PAGE-GR
        PAGE-SP
        SAL-ARABIC
        SAL-FOLIO
        SAL-PAGE
        SAL-SERG
        SAL-TEMP
        SALTURKISH
        SHELBYSER
        SHELBYTITL
        SOUTH-MEZZ
        STACKS
        TECH-RPTS
        UNCAT
      ],
      'SAL3' => %w[
        ASK@EASIA
        ATLASES
        BUS-STACKS
        CALIF-DOCS
        CHINESE
        FED-DOCS
        HY-PAGE-EA
        IC-NEWS
        IC-STATS
        INDEXES
        INPROCESS
        INTL-DOCS
        JAPANESE
        KOREAN
        L-PAGE-EA
        LOCKED-STK
        MEDIA-MTXT
        MICROTEXT
        ON-ORDER
        PAGE-EA
        PAGE-GR
        PAGE-SP
        R-STACKS
        RARE-BOOKS
        RECORDINGS
        SAFETY
        SAL-PAGE
        SCORES
        SOUTH-MEZZ
        STACKS
        STORAGE
      ],
      'SCIENCE' => %w[
        INPROCESS
        ON-ORDER
        POPSCI
        SERIALS
        SHELBYSER
        SHELBYTITL
        STACKS
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
