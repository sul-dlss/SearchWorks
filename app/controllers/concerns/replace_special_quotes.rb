module ReplaceSpecialQuotes
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_filter)
      before_filter :replace_special_quotes, only: :index
    end
  end

  private

  def replace_special_quotes
    modifiable_params_keys.each do |param|
      if params.has_key?(param) and params[param].present?
        special_quote_characters.each do |char|
          params[param].gsub!(/#{char}/, '"')
        end
      end
    end
  end

  def special_quote_characters
    ["\u00AB", "\u00BB", "\u2018", "\u2019", "\u201A", "\u201B", "\u201C",
     "\u201D", "\u201E", "\u201F", "\u2039", "\u203A", "\u300C", "\u300D",
     "\u300E", "\u300F", "\u301D", "\u301E", "\u301F", "\uFE41", "\uFE42",
     "\uFE43", "\uFE44", "\uFF02", "\uFF62", "\uFF63"]
  end
end
