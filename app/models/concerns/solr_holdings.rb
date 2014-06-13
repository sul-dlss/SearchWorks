module SolrHoldings
  def holdings
    @holdings ||= Holdings.new(self)
  end
end
