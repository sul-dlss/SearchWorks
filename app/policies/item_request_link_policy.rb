# This determines whether we should display a request link to the user
class ItemRequestLinkPolicy
  def initialize(item:)
    @item = item
  end

  def show?
    return folio_holdable? if item.folio_item?

    # on-order items (without a folio item) may be title-level requestable
    # but we can't evaluate circ rules (because there's no item) to figure that out
    item.on_order?
  end

  # Check to see if request types include hold or recall.
  # This is used to make sure live lookup can't create a request link for items that aren't eligible for hold/recall.
  def item_allows_hold_recall?
    item.allowed_request_types.include?('Hold') ||
      item.allowed_request_types.include?('Recall')
  end

  private

  attr_reader :item

  def folio_holdable?
    return false unless Settings.folio_hold_recall_statuses.include?(item.folio_status)

    item.allowed_request_types.include?('Hold') ||
      item.allowed_request_types.include?('Recall')
  end
end
