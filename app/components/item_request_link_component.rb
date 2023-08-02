class ItemRequestLinkComponent < ViewComponent::Base
  LEGACY_ONSITE_LOCATIONS = %w(PAGE-AR PAGE-AS PAGE-EA PAGE-ED PAGE-EN PAGE-ES PAGE-GR
                               PAGE-HA PAGE-HP PAGE-HV PAGE-LW PAGE-MA PAGE-MD PAGE-MU PAGE-RM PAGE-SP).freeze

  FOLIO_ONSITE_LOCATIONS = %w(
    SAL3-PAGE-AR
    ART-PAGE-AR
    SAL3-PAGE-AS
    SAL3-PAGE-EA
    EAL-PAGE-EA
    SAL-PAGE-EA
    SAL3-PAGE-ED
    EDU-PAGE-ED
    SAL3-PAGE-EN
    ENG-PAGE-EN
    SAL3-PAGE-ES
    EAR-PAGE-ES
    SAL-PAGE-GR
    SAL3-PAGE-GR
    GRE-PAGE-GR
    MAR-PAGE-MA
    SAL3-PAGE-MA
    SAL3-PAGE-MD
    MEDIA-PAGE-MD
    SAL3-PAGE-MU
    MUS-PAGE-MU
    SAL3-PAGE-RM
    RUM-PAGE-RM
    SAL3-PAGE-SP
  ).freeze

  attr_reader :item, :classes

  delegate :document, :library, :home_location, :barcode, to: :item

  def initialize(item:, classes: %w[btn btn-default btn-xs request-button])
    super

    @item = item
    @classes = classes
  end

  def call
    link_to(
      link_text,
      link_href,
      target: '_blank',
      rel: 'nofollow noopener',
      class: classes.join(' ')
    )
  end

  def render?
    policy.show?
  end

  private

  def policy
    ItemRequestLinkPolicy.new(item:)
  end

  def link_href
    helpers.request_url(
      document,
      library:,
      location: home_location,
      barcode:
    )
  end

  def link_text
    locale_key = if on_site_location?
                   'request_on_site' # e.g. "Request on-site access"
                 else
                   'default'
                 end

    t(locale_key, default: :default, scope: 'searchworks.request_link')
  end

  def on_site_location?
    (item.folio_item? && FOLIO_ONSITE_LOCATIONS.include?(item.effective_location.location.code)) ||
      LEGACY_ONSITE_LOCATIONS.include?(home_location)
  end
end
