# frozen_string_literal: true

module Druid
  def druid
    self[:druid] || marc_links.managed_purls.map(&:druid)&.first
  end
end
