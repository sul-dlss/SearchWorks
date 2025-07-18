# frozen_string_literal: true

class AdvancedClausePresenter < Blacklight::ClausePresenter
  ##
  # Get the displayable version of a facet's value.
  # If the advanced search clause is an "OR" condition, we want
  # to combine the terms using a comma.
  #
  # @return [String]
  def label
    return user_parameters[:query] if user_parameters[:op] == 'must'

    user_parameters[:query].parameterize(separator: ', ')
  end

  # The prefix method is used to generate what should appear in the selected
  # constraint for an advanced search clause query.
  def prefix
    user_parameters[:op] == 'must' ? 'Contains <span class="fw-bold">ALL</span>' : 'Contains <span class="fw-bold">ANY</span>'
  end
end
