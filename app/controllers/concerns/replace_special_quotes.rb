# frozen_string_literal: true

##
# Module to be mixed into a controller to replace
# special quote characters on the index action
module ReplaceSpecialQuotes
  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_action)
      before_action :replace_special_quotes, only: :index
    end
  end

  private

  def replace_special_quotes
    replace_single_quotes_from_hash params, :q

    params[:clause]&.each_value do |value|
      replace_single_quotes_from_hash value, :query
    end
  end

  def replace_single_quotes_from_hash(hash, key)
    return if hash[key].blank?

    replace_single_quotes_from_param(hash, key)

    special_quote_characters.each do |char|
      hash[key] = hash[key].gsub(/#{char}/, '"')
    end
  end

  def replace_single_quotes_from_param(hash, key)
    special_single_quotation_marks.each do |open_quote, close_quote|
      opens = hash[key].scan(open_quote)
      closes = hash[key].scan(close_quote)

      # only uneven single quotes
      next unless opens.length != closes.length

      hash[key] = hash[key].sub(/#{open_quote}/, "'") if opens.length == 1
      hash[key] = hash[key].sub(/#{close_quote}/, "'") if closes.length == 1
    end
  end

  def special_single_quotation_marks
    [["\u2018", "\u2019"], ["\u201A", "\u201B"]]
  end

  def special_quote_characters
    ["\u00AB", "\u00BB", "\u2018", "\u2019", "\u201A", "\u201B", "\u201C",
     "\u201D", "\u201E", "\u201F", "\u2039", "\u203A", "\u300C", "\u300D",
     "\u300E", "\u300F", "\u301D", "\u301E", "\u301F", "\uFE41", "\uFE42",
     "\uFE43", "\uFE44", "\uFF02", "\uFF62", "\uFF63"]
  end
end
