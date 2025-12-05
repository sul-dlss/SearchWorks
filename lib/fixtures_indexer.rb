# frozen_string_literal: true

class FixturesIndexer
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

  private

  def index
    # fixtures = SolrFixtureLoader.load_all
    fixtures = [SolrFixtureLoader.load('10678312.yml')]
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
