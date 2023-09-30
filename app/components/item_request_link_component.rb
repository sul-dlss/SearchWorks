class ItemRequestLinkComponent < ViewComponent::Base
  attr_reader :item, :classes

  delegate :document, :library, :home_location, :barcode, to: :item

  def initialize(item:, classes: %w[btn btn-xs request-button])
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
    t('searchworks.request_link.default')
  end
end
