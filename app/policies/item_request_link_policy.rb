# This determines whether we should display a request link to the user
class ItemRequestLinkPolicy
  def initialize(item:)
    @item = item
  end

  def show?
    (item.folio_item? && folio_holdable?) || item.on_order?
  end

  private

  attr_reader :item

  delegate :document, :library, :home_location, :barcode, to: :item

  def folio_holdable?
    return false unless Settings.folio_hold_recall_statuses.include?(item.folio_status)

    (item.allowed_request_types.include?('Hold') ||
      item.allowed_request_types.include?('Recall'))
  end

  def current_location
    item.current_location.code
  end
end
