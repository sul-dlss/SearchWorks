# Harvests some fixture data from production and stores it in yaml files.
# Usage:
#   bin/rails runner "FixtureHarvester.harvest_all"
#
# You can then load the yaml into solr using `rake searchworks:fixtures'
class FixtureHarvester
  FIXTURES = [
    '5488000', # Bound with parent
    '2279186', # Bound with (no Folio items) (TODO: merge with 20 or 23?)
    '14136548', # Online resource (no Folio items)
    '4085072', # A collection of images (TODO: merge with 24?)
    '13553090', # A uniform title (dotdotdotdot)
    '2472159' # one hrid for multiple purl images (TODO: merge with 8923346, 20, or 23?)
  ].freeze

  def self.harvest_all
    FIXTURES.each { |id| harvest(id) }
  end

  def self.harvest(id)
    response = conn.get("#{id}.json")
    yaml = response.body.dig('response', 'document').except('_version_').to_yaml
    File.write("spec/fixtures/solr_documents/#{id}.yml", yaml)
  end

  def self.conn
    Faraday.new 'https://searchworks.stanford.edu/view/' do |conn|
      conn.response :json, content_type: /\bjson$/

      conn.adapter Faraday.default_adapter
    end
  end
end