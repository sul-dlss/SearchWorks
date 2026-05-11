# frozen_string_literal: true

module SearchRelevancyLogging
  extend ActiveSupport::Concern

  included do
    after_action :log_search_data, only: :index
    after_action :log_relevancy_data, only: :show
  end

  # Override blacklight to also keep track of how many searches the user has done this session
  def add_to_search_history(*args)
    super

    session[:history_counter] ||= 0
    session[:history_counter] += 1
  end

  def log_search_data
    return unless params[:q] || params[:search_field] || params[:f]

    search_logger.info([
      Time.zone.now.strftime('%Y-%m-%d %H:%M:%S.%L'),
      request.remote_ip,
      controller_name,
      action_name,
      "search=#{search_session['id']}",
      "counter=#{session[:history_counter].to_i}",
      "page=#{params[:page].to_i}",
      "numFound=#{@response.response[:numFound]}",
      "q=#{params[:q]&.gsub(/\s+/, ' ')}",
      params.except(:utf8, :q, :action, :controller).to_json.gsub(/\s+/, ' ')
    ].join("\t"))
  rescue StandardError => e
    Honeybadger.notify(e)
  end

  def log_relevancy_data
    query_params = current_search_session&.query_params || {}

    search_logger.info([
      Time.zone.now.strftime('%Y-%m-%d %H:%M:%S.%L'),
      request.remote_ip,
      controller_name,
      action_name,
      "search=#{search_session['id']}",
      "doc=#{params[:id]}",
      "pos=#{search_session['counter']}",
      "total=#{search_session['total']}",
      "q=#{query_params[:q]&.gsub(/\s+/, ' ')}",
      query_params.slice(:f, :search_field, :sort, :format).to_json.gsub(/\s+/, ' ')
    ].join("\t"))
  rescue StandardError => e
    Honeybadger.notify(e)
  end

  def search_logger
    Rails.application.config.search_logger
  end
end
