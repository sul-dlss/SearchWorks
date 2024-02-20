LocationWithHoldings = Data.define(:location_code, :holdings) do
    def name
      holdings.first.effective_location.name
    end
  end
