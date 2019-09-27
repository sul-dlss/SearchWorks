# frozen_string_literal: true

class SitemapController < ApplicationController
  def index
    @access_list = access_list
  end

  def show
    @solr_response = Blacklight.default_index.connection.select({
      params: {
        q: "{!prefix f=hashed_id_si v=#{access_params}}",
        fl: 'id,last_updated'
      }
    })
  end

  private

  def access_params
    params.require(:id)
  end

  def max_documents
    Rails.cache.fetch('index_max_docs', expires_in: 1.day) do
      Blacklight.default_index.connection.select({ params: { q: '*:*', rows: 0 } })['response']['numFound']
    end
  end

  def access_list
    average_chunk = [10000, max_documents].min # Sufficiently less than 50,000 max per sitemap
    access = (Math.log(max_documents / average_chunk) / Math.log(16)).ceil
    (0...(16**access))
      .to_a
      .map { |v| v.to_s(16).rjust(access, '0') }
  end
end
