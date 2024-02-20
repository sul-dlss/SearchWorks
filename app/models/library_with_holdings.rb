LibraryWithHoldings = Data.define(:library_code, :holdings) do
    def name
      holdings.first.effective_location.library.name
    end
  end
