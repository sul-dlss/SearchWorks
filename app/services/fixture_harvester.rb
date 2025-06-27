# frozen_string_literal: true

# Harvests some fixture data from production and stores it in yaml files.
# Usage:
#   bin/rails runner "FixtureHarvester.harvest_all"
#
# You can then load the yaml into solr using `rake searchworks:fixtures'
class FixtureHarvester
  FIXTURES = [
    '5488000', # Bound with parent
    '2279186', # Bound with (no Folio items) (TODO: merge with 20 or 23?)
    '14136548', # Online resource (no Folio items, no shelfkey)
    'in00000053236', # Online resource (no Folio items, has shelfkey)
    '4085072', # A collection of images (TODO: merge with 24?)
    '13553090', # A uniform title (dotdotdotdot, TODO: merge with 18?)
    '2472159', # one hrid for multiple purl images (TODO: merge with 8923346, 20, or 23?)
    'L210044', # Has a large number of online links.
    '2308798', # child of 5488000, for third holding
    '2312336', # child of 5488000, for third holding
    '2300812', # child of 5488000, for third holding
    '2285763', # child of 5488000, for third holding
    '2285756', # child of 5488000, for second holding
    '4085177', # Finding aid with many call numbers
    '6631609', # Mix of circulating and non-circulating w/finding aid
    'L210044', # Has a large number of online links.
    '14059621', # Has an edition (marc 250)
    'in00000149820', # 700 example with a translator
    '12324130', # 710 example with a corporate name & subordinate unit
    '10689066', # Has editor roles
    '14434124', # Has duplicate author names and linking to alternative script
    '219330', # has a 700t which indicates an included work
    'in00000382380', # a dissertation

    '1391872', # single item in Green Stacks
    '10678312', # multiple items in Green Stacks
    '13840972', # lots of items
    '402381', # multiple items in multiple locations
    'in00000444367', # online item
    '10838998', # small number of items in multiple libraries and available online
    '3402192', # lots of copies, some checked out
    '14239755', # temporary location
    '513384', # single item with an MHLD in another library
    '342324' # serial on-exhibit
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
