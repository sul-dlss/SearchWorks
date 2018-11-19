# frozen_string_literal: true

##
# Class containing logic for feedback form params parsing
class FeedbackMailerParser
  attr_reader :params, :ip

  def initialize(params, ip)
    @params = params
    @ip = ip
  end

  def name
    params.fetch(:name, 'No name given')
  end

  def email
    params.fetch(:to, 'No email given')
  end

  def message
    params[:message].to_s
  end

  def url
    params[:url]
  end

  def user_agent
    params[:user_agent]
  end

  def viewport
    params[:viewport]
  end

  def resource_name
    params[:resource_name]
  end

  def problem_url
    params[:problem_url]
  end

  def last_search
    params[:last_search]
  end
end
