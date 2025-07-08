module EdsSearchable
  extend ActiveSupport::Concern
  included do
    around_action :manage_eds_session_token
  end

  def search_service
    eds_params = {
      guest: session['eds_guest'],
      session_token: session[Settings.EDS_SESSION_TOKEN_KEY]
    }
    @search_service ||= Eds::SearchService.new(blacklight_config, params, eds_params)
  end

  # EDS uses the session token to maintain some kind of state across requests (and also uses it
  # to handle guest state). Therefore, we need to establish a session token before making EDS requests,
  # and also update the session token if EDS tells us the session token expired after making the request(s).
  def manage_eds_session_token
    # we don't need to mint a token for the home page
    if action_name == 'index' && !has_search_parameters?
      yield
      return
    end

    setup_eds_session

    yield

    # Update the EDS session token in the user's session
    used_token = search_service.session_token

    session[Settings.EDS_SESSION_TOKEN_KEY] = used_token if session[Settings.EDS_SESSION_TOKEN_KEY] != used_token
  end

  # Reuse the EDS session token if available in the user's session data,
  # otherwise establish a session
  def setup_eds_session
    return if session[Settings.EDS_SESSION_TOKEN_KEY].present?

    session['eds_guest'] = !on_campus_or_su_affiliated_user?

    session[Settings.EDS_SESSION_TOKEN_KEY] = Eds::Session.new(
      guest: session['eds_guest'],
      caller: 'new-session'
    ).session_token

    return unless current_user

    Honeybadger.add_breadcrumb('Established EDS session', metadata: {
                                 eds_guest: session['eds_guest'],
                                 eds_session_token: session[Settings.EDS_SESSION_TOKEN_KEY],
                                 request_ip: request.remote_ip,
                                 affiliations: current_user.affiliations,
                                 person_affiliations: current_user.person_affiliations,
                                 entitlements: current_user.entitlements
                               })
  end
end
