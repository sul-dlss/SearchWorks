module ReplaceSpecialQuotes
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_action)
      before_action :replace_special_quotes, only: :index
    end
  end

  private

  def replace_special_quotes
    modifiable_params_keys.each do |param|
      if params.has_key?(param) and params[param].present?
        replace_single_quotes_from_param(params[param])

        special_quote_characters.each do |char|
          params[param].gsub!(/#{char}/, '"')
        end
      end
    end
  end

  def replace_single_quotes_from_param(param)
    special_single_quotation_marks.each do |open_quote, close_quote|
      opens = param.scan(open_quote)
      closes = param.scan(close_quote)

      if opens.length != closes.length # uneven single quotes
        if opens.length == 1
          param.sub!(/#{open_quote}/, "'")
        end

        if closes.length == 1
          param.sub!(/#{close_quote}/, "'")
        end
      end
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
