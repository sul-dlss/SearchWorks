# frozen_string_literal: true

module SearchworksMcp
  # Builds the Blacklight and EDS search services that tools query.
  module SearchServices
    module_function

    def catalog(controller, params = {})
      config = CatalogController.blacklight_config
      state = Blacklight::SearchState.new(params, config, controller)
      Blacklight::SearchService.new(config: config, search_state: state)
    end

    # MCP clients are anonymous, so EDS is always queried as a guest.
    def eds(params = {})
      eds_params = {
        guest: true,
        session_token: Eds::Session.new(guest: true, caller: "mcp-server").session_token
      }
      Eds::SearchService.new(ArticlesController.blacklight_config, params, eds_params)
    end
  end
end
