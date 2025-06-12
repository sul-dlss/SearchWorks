# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogSearchService do
  subject(:service) { described_class.new }

  let(:response) { JSON.dump({ response: { docs: [] } }) }
  let(:query) { 'my query' }

  before do
    stub_request(:get, /.*/).to_return(body: response)
  end

  it { expect(service).to be_an AbstractSearchService }
end
