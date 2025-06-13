# frozen_string_literal: true

require Rails.root.join("spec/fixtures/marc_records/marc_856_fixtures")
require Rails.root.join("spec/fixtures/marc_records/marc_metadata_fixtures")
require Rails.root.join("spec/fixtures/mods_records/mods_fixtures")

class SolrFixtureLoader
  STRUCT_KEYS = %w[
    works_struct author_struct marc_links_struct summary_struct
    uniform_title_display_struct holdings_json_struct toc_struct
    item_display_struct browse_nearby_struct collection_struct
  ].freeze

  class ErbContext
    include Marc856Fixtures
    include MarcMetadataFixtures
    include ModsFixtures

    def context_binding
      binding
    end
  end

  def self.load(filename, with_json: true)
    file_path = Rails.root.join("spec/fixtures/solr_documents/#{filename}")
    template = ERB.new(File.read(file_path))
    rendered = template.result(ErbContext.new.context_binding)
    data = YAML.safe_load(rendered, aliases: true)

    STRUCT_KEYS.each do |key|
      next unless data[key]

      data[key] = Array(data[key]).map do |entry|
        with_json ? entry.to_json : entry
      end
    end

    data
  end

  def self.file_list
    @file_list ||= Dir[Rails.root.join("spec/fixtures/solr_documents/*.yml").to_s]
  end

  def self.load_all
    file_list.map { |file| load(File.basename(file)) }
  end
end
