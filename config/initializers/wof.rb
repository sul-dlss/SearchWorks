require 'json'

Wof = JSON.parse(
  File.read(
    Rails.root.join('wof_lookup.json')
  )
)
