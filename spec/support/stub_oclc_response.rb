# frozen_string_literal: true

##
# Simple module included for RSpec tests to stub OCLC citation responses
module StubOclcResponse
  def stub_oclc_response(response, opts = {})
    allow_any_instance_of(Citation).to receive(:field).and_return(opts[:for]) if opts[:for]
    allow_any_instance_of(Citation).to receive(:response).and_return(response)
  end
end

RSpec.configure do |config|
  config.include StubOclcResponse
end
