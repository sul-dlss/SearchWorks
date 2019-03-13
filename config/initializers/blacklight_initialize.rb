# Blacklight.secret_key = Settings.BLACKLIGHT_SECRET_KEY

# EDS identifier rules (e.g., db__acid) where acid has all sorts of different punctuation
Blacklight::Engine.config.routes.identifier_constraint = /[^\/]+/
