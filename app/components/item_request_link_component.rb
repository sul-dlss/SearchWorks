class ItemRequestLinkComponent < ViewComponent::Base
  REQUEST_ONSITE_LOCATIONS = %w(PAGE-AR PAGE-AS PAGE-EA PAGE-ED PAGE-EN PAGE-ES PAGE-GR
     PAGE-HA PAGE-HP PAGE-HV PAGE-LW PAGE-MA PAGE-MD PAGE-MU PAGE-RM PAGE-SP)

  delegate :document, :library, :home_location, :barcode, to: :@item

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
      class: @classes.join(' ')
    )
  end

  def render?
    policy.show?
  end

  private

  def policy
    ItemRequestLinkPolicy.new(item: @item)
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
    locale_key = 'searchworks.request_link.default'

    # e.g. "Request on-site access"
    locale_key = 'searchworks.request_link.request_on_site' if REQUEST_ONSITE_LOCATIONS.include?(home_location)

    t(locale_key)
  end
end
