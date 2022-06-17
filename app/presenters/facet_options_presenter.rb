class FacetOptionsPresenter
  def initialize(params:, context:)
    @params = params
    @context = context
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
    FACET_FIELD = 'eds_search_limiters_facet'.freeze
    delegate :facet_in_params?, :path_for_facet, :search_action_path, :search_state, to: :context

    def initialize(limiter, params, context)
      @limiter = limiter
      @params = params
      @context = context
    end

    def id
      limiter['Id']
    end

    def label
      limiter['Label']
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
      facet_in_params?(FACET_FIELD, label)
    end

    def search_url
      if selected?
        search_action_path(search_state.filter(FACET_FIELD).remove(label).to_h)
      else
        path_for_facet(FACET_FIELD, label)
      end
    end

    private

    attr_reader :limiter, :params, :context
  end
end
