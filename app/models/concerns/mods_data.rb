module ModsData
  extend ActiveSupport::Concern
  included do
    include ModsDisplay::ModelExtension
    include ModsDisplay::ControllerExtension
    mods_xml_source do |model|
      model[:modsxml]
    end
    configure_mods_display do
    end
  end
  def mods
    return nil unless self[:modsxml]
    @mods ||= render_mods_display(self)
  end
  def prettified_mods
    return nil unless self["modsxml"]
    @prettified_mods ||= CodeRay::Duo[:xml, :div].highlight(self["modsxml"]).html_safe
  end
end
