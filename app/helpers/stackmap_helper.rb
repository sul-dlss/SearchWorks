module StackmapHelper
  def stackmap_api_url(library)
    settings = Settings.libraries[library]
    return settings.stackmap_api if settings

    Honeybadger.notify("Called stackmapable_library? on an unknown library", context: { library: library })
    false
  end
end
