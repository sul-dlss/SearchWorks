# frozen_string_literal: true

##
# Model the list of search tips and provides a convenience method to return a random tip
class SearchTips
  def self.random
    new.random
  end

  def initialize(all_tips = Settings.SEARCH_TIPS)
    @all_tips = all_tips
  end

  def random
    tip = all_tips.sample
    Tip.new(label: tip.label, body: tip.body)
  end

  private

  attr_reader :all_tips

  ##
  # Model a single tip that has a label and body
  # value and defines a partial path for rendering
  class Tip
    attr_reader :label, :body
    def initialize(label:, body:)
      @label = label
      @body = body
    end

    def to_partial_path
      'articles/search_tip'
    end
  end
end
