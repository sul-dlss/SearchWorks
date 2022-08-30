class NearbyOnShelf
  def self.around_callnumber(callnumber, search_service:, per: 24, **kwargs)
    return [] unless callnumber

    before = NearbyOnShelf.reverse(search_service: search_service).callnumbers(callnumber.reverse_shelfkey, per: per / 2, **kwargs)
    current_and_after = NearbyOnShelf.forward(search_service: search_service).callnumbers(callnumber.shelfkey, per: per / 2, incl: true, **kwargs)

    # it's possible a document occurs before + after the current callnumber, so we have to re-uniq the result
    (before + current_and_after).uniq { |x| x.document&.id }
  end

  def self.forward(field: 'shelfkey', **kwargs)
    NearbyOnShelf.new(field: field, **kwargs)
  end

  def self.reverse(field: 'reverse_shelfkey', **kwargs)
    NearbyOnShelf.new(field: field, **kwargs)
  end

  attr_reader :field, :search_service

  delegate :repository, to: :search_service

  def initialize(field:, search_service:)
    @field = field
    @search_service = search_service
  end

  # given a shelfkey or reverse shelfkey (for a lopped call number), get the
  #  text for the next window of items
  # @return [Array<Holdings::Callnumber>] a sorted array of callnumbers
  def callnumbers(starting_value, per: 24, incl: false, max_docs: 100)
    desired_values = fetch_next_terms('terms.limit' => per, 'terms.lower' => starting_value, 'terms.lower.incl' => incl)

    # Get the documents for a set of shelf keys
    response, = search_service.search_results do |builder|
      builder.rows = max_docs
      builder.where(field => desired_values.compact)
    end

    # Get only the callnumber objects that match the shelfkeys
    spines = response.documents.flat_map(&:callnumbers).select do |callnumber|
      desired_values.include?(callnumber.send(field))
    end

    spines.uniq(&:spine_sort_key).uniq { |x| x.document&.id }.sort_by(&:spine_sort_key).each do |callnumber|
      callnumber.document.preferred_callnumber = callnumber
    end
  end

  private

  def fetch_next_terms(params)
    # TermsComponent Query to get the terms
    solr_params = {
      'terms.fl' => field,
      'terms.sort' => 'index',
      'json.nl' => 'map'
    }.merge(params)

    solr_response = repository.send_and_receive('alphaTerms', solr_params)
    solr_response.dig('terms', field)&.keys || []
  end
end
