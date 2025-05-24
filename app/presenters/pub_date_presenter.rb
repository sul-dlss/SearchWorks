# frozen_string_literal: true

# eds_pub_date_facet value is YYYY-MM/YYYY-MM we want to display the human readable value
# i.e. Since May 2025
class PubDatePresenter < Blacklight::FacetItemPresenter
  def constraint_label
    formatted_date = Date.strptime(value, "%Y-%m").strftime("%B %Y")
    "Since #{formatted_date}"
  rescue StandardError
    value
  end
end
