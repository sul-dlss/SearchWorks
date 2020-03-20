require 'json'

wof_lookup_content = begin
  File.read(Rails.root.join('wof_lookup.json'))
rescue Errno::ENOENT
  '{}'
end

Wof = JSON.parse(wof_lookup_content)
