# frozen_string_literal: true

class LibrarySettings
  def self.name(library_code)
    config(library_code).name
  end

  def self.config(library_code)
    Settings.libraries[library_code] || Settings.libraries.default
  end
end
