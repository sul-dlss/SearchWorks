# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Eds::SearchBuilder do
  subject(:search_builder) { described_class.new(scope) }

  let(:scope) { instance_double(ArticlesController, blacklight_config: ArticlesController.blacklight_config, search_state_class: nil, action_name: 'index', controller_name: 'articles') }

  it 'sets the default parameters' do
    expect(search_builder.with({}).to_hash).to include(
      "RetrievalCriteria" => { "PageNumber" => 1, "ResultsPerPage" => 20, "View" => "detailed" },
      "SearchCriteria" => { "IncludeFacets" => "y", "Queries" => [{ "Term" => nil }], "SearchMode" => "all", "Sort" => "relevance" }
    )
  end
end
