ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'CJK'
  inflect.acronym 'IP'
  inflect.acronym 'MHLD'
end

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "purl_embed" => "PURLEmbed"
  )
end
