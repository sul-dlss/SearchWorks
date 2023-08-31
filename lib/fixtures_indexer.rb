require "#{Rails.root}/spec/fixtures/marc_records/marc_856_fixtures"
require "#{Rails.root}/spec/fixtures/marc_records/marc_metadata_fixtures"
require "#{Rails.root}/spec/fixtures/mods_records/mods_fixtures"

class FixturesIndexer
  include Marc856Fixtures
  include MarcMetadataFixtures
  include ModsFixtures

  def self.run
    FixturesIndexer.new.run
  end

  def initialize
    validate!

    @solr = Blacklight.default_index.connection
  end

  def validate!
    return true if configured_solr_wrapper_collection == configured_blacklight_collection

    raise(
      ArgumentError,
      <<-LONGTEXT.strip_heredoc
        You are trying to index to the "#{configured_blacklight_collection}" collection,
        which is not the same as what is configured in .solr_wrapper.yml (#{configured_solr_wrapper_collection}).
        You may be running the inexer against a remote collection, which is not advisable.
      LONGTEXT
    )
  end

  def run
    index
    commit
  end

  def fixtures
    @fixtures ||= file_list.map do |file|
      fixture_template = ERB.new(File.read(file))
      rendered_template = fixture_template.result(binding)
      data = YAML::load rendered_template
      data[:item_display_struct] &&= data[:item_display_struct].map(&:to_json)
      data
    end
  end

  def file_list
    @file_list ||= Dir["#{Rails.root}/spec/fixtures/solr_documents/*.yml"]
  end

  private

  def index
    @solr.add fixtures
  end

  def commit
    @solr.commit
  end

  def configured_solr_wrapper_collection
    SolrWrapper.instance.config.options[:collection]['name']
  end

  def configured_blacklight_collection
    Blacklight.default_index.connection.uri.path.match(%r{/([\w+-]+)/?$}).captures.first
  end
end
