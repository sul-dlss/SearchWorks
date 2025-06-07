# frozen_string_literal: true

class FacetOptionsPresenter
  def initialize(params:, context:)
    @params = params
    @context = context
  end

  def month_facets
    (0..2).map do |i|
      date = Time.zone.today << i
      PubDateLimiter.new({
                           'Id' => 'DT1',
                           'SearchField' => "#{date.strftime('%Y-%m')}/#{Time.zone.today.strftime('%Y-%m')}",
                           'Label' => "Since #{date.strftime('%B %Y')}"
                         }, params, context)
    end
  end

  def limiters
    @limiters ||= available_limiters.map do |limiter|
      Limiter.new(limiter, params, context)
    end
    @limiters = @limiters.select { |l| l.type == 'select' }.sort_by(&:order)
  end

  private

  attr_reader :params, :context

  def available_limiters
    eds_session.info.available_search_criteria['AvailableLimiters'] || []
  end

  def eds_session
    @eds_session ||= Eds::Session.new(eds_params)
  end

  def eds_params
    {
      caller: 'bl-search',
      guest: context.session['eds_guest'],
      session_token: context.session['eds_session_token']
    }
  end

  class Limiter
    delegate :facet_item_presenter, :search_action_path, :search_state, :facet_configuration_for_field, to: :context

    def initialize(limiter, params, context)
      @limiter = limiter
      @params = params
      @context = context
    end

    def facet_field
      'eds_search_limiters_facet'
    end

    def id
      limiter['Id']
    end

    def label
      limiter['Label']
    end

    def search_value
      label
    end

    def type
      limiter['Type']
    end

    def order
      (limiter['Order'] || 0).to_i
    end

    def enabled_by_default?
      limiter['DefaultOn'] == 'y'
    end

    def selected?
      search_state.filter(config).include?(search_value)
    end

    def search_url
      if selected?
        search_action_path(search_state.filter(facet_field).remove(search_value).to_h)
      else
        (config.item_presenter || Blacklight::FacetItemPresenter).new(search_value, config, context, facet_field).href
      end
    end

    def config
      facet_configuration_for_field(facet_field)
    end

    private

    attr_reader :limiter, :params, :context
  end

  class PubDateLimiter < Limiter
    def facet_field
      'eds_pub_date_facet'
    end

    def search_value
      limiter['SearchField']
    end
  end
end
