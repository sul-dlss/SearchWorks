class ItemRequestLinkComponent < LocationRequestLinkComponent
  delegate :document, :library, :location, to: :item

  def initialize(item:)
    @item = item
  end
end
