# frozen_string_literal: true

# This determines whether we should display a request link to the user
class ItemRequestLinkPolicy
  def initialize(item:, rtac: nil)
    @item = item
    @rtac = rtac
  end

  def show?
    return folio_holdable? if item.folio_item?

    # on-order items (without a folio item) may be title-level requestable
    # but we can't evaluate circ rules (because there's no item) to figure that out;
    # SPEC does not allow requests until there is a folio item present
    item.on_order? unless item.library == 'SPEC-COLL'
  end

  # Check to see if request types include hold or recall.
  # This is used to make sure live lookup can't create a request link for items that aren't eligible for hold/recall.
  def item_allows_hold_recall?
    item.allowed_request_types.include?('Hold') ||
      item.allowed_request_types.include?('Recall')
  end

  private

  attr_reader :item, :rtac

  def folio_holdable?
    if rtac
      return false unless Settings.folio_hold_recall_statuses.include?(rtac[:status])
    else
      return false unless Settings.folio_hold_recall_statuses.include?(item.folio_status)
    end

    item_allows_hold_recall?
  end
end
