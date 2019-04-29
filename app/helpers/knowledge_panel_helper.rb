module KnowledgePanelHelper
  def knowledge_panel_uri_map(authorities, rwos)
    uris = [authorities, rwos].flatten.compact

    uris.group_by do |u|
      URI.parse(u).host
    end
  end
end
