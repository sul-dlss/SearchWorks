class OpensearchController < ApplicationController
  def opensearch
    response.headers['Content-Type'] = 'application/opensearchdescription+xml; charset=utf-8'
  end
end
