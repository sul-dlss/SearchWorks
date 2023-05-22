module StackmapHelper
  def stackmap_api_url(library)
    return Settings.libraries.LAW.stackmap_api if library == 'LAW'

    Settings.libraries.default.stackmap_api
  end
end
