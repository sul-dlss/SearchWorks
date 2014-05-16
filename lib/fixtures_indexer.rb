require "#{Rails.root}/spec/fixtures/marc_records/marc_856_fixtures"
require "#{Rails.root}/spec/fixtures/marc_records/marc_metadata_fixtures"
class FixturesIndexer
  include Marc856Fixtures
  include MarcMetadataFixtures
  def self.run
    FixturesIndexer.new.run
  end
  def initialize
    @solr = Blacklight.solr
  end
  def run
    index
    commit
  end
  def fixtures
    @fixtures ||= file_list.map do |file|
      fixture_template = ERB.new(File.read(file))
      rendered_template = fixture_template.result(binding)
      YAML::load rendered_template
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
end
