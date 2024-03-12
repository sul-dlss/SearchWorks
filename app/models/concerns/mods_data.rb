# frozen_string_literal: true

module ModsData
  extend ActiveSupport::Concern

  def mods?
    self[:modsxml].present?
  end

  def mods
    return nil unless mods?

    @mods ||= ModsDisplay::Record.new(self[:modsxml]).mods_display_html
  end

  def prettified_mods
    return nil unless mods?

    @prettified_mods ||= CodeRay::Duo[:xml, :div].highlight(self["modsxml"]).html_safe
  end

  ##
  # Convenience accessors and parsers for mods_display content already indexed

  ##
  # A ModsDisplay::Values object dumped while indexing. The object is needed
  # as there is there is some necessary display logic.
  def mods_display_name
    fetch(:author_struct, [])
  end

  def mods_abstract
    fetch(:summary_display, [])&.uniq
  end
end
