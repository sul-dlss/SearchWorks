class FixturesIndexer
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
      YAML::load File.open(file)
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
