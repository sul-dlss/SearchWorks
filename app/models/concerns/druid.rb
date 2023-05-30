module Druid
  def druid
    self[:druid] || index_links.managed_purls.map(&:druid)&.first
  end
end
