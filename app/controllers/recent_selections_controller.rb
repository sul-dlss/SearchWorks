# frozen_string_literal: true

class RecentSelectionsController < ApplicationController
  include SelectionsCount

  def index
    redirect_to(root_url) unless request.xhr?

    @catalog_count = selections_counts.catalog
    @article_count = selections_counts.articles

    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end
end
