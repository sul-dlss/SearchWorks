module StackmapHelper
  def stackmap_api_url(library)
    return Settings.STACKMAP_API_URL.LAW if library == 'LAW'

    Settings.STACKMAP_API_URL.DEFAULT
  end
end
