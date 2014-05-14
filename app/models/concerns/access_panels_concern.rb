module AccessPanelsConcern
  def access_panels
    @access_panels ||= AccessPanels.new(self)
  end
end
