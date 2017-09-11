require 'rails_helper'

RSpec.describe ArticleSearchService do
  subject(:service) { described_class.new }
  let(:response) { JSON.dump(response: { docs: [] }) }
  let(:query) { ArticleSearchService::Request.new('my query') }
  
  before do
    allow(Faraday).to receive(:get).and_return(instance_double(Faraday::Response,
                                                               success?: true,
                                                               body: response))
  end

  it { expect(service).to be_an AbstractSearchService }
  it { expect(service.search(query)).to be_an ArticleSearchService::Response }
end
