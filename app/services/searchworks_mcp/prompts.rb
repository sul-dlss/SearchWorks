# frozen_string_literal: true

module SearchworksMcp
  # MCP prompt templates offered to users as guided entry points.
  module Prompts
    MAX_ARGUMENT_LENGTH = 500

    FIND_ITEM = MCP::Prompt.define(
      name: "find_item",
      title: "Find an item in the library",
      description: "Find a book, journal, recording, map, or other catalog item at Stanford Libraries and " \
                   "report where it is and how to get it.",
      arguments: [
        MCP::Prompt::Argument.new(
          name: "item",
          title: "Item",
          description: "Title, author, ISBN, or a description of what you are looking for",
          required: true
        ),
        MCP::Prompt::Argument.new(
          name: "library",
          title: "Preferred library",
          description: "Optional library you would like to get the item from, such as Green Library"
        )
      ]
    ) do |args|
      Prompts.find_item_result(item: Prompts.clean_argument(args[:item]), library: Prompts.clean_argument(args[:library]))
    end

    def self.find_item_result(item:, library:)
      lines = [
        "Find this item in the Stanford Libraries catalog: #{item}",
        "",
        "1. Search with catalog_search_tool. Use search_field title or author when the request is clearly a " \
        "title or an author; otherwise, including for ISBNs, use the default all_fields search.",
        "2. Pick the result that best matches the request. If several results are plausible (different " \
        "editions, formats, or similarly titled works), list the top few briefly and say which one you chose.",
        "3. Call get_availability with the chosen result's id.",
        "4. Answer with the title, author, and date; each available copy's library, location, and call " \
        "number; any online access links; the request_url when present; and the canonical SearchWorks URL.",
        "5. If nothing matches, say so and suggest a broader search or a different spelling. Do not invent records."
      ]
      lines << "" << "Prefer copies held at #{library}, but mention other locations too." if library.present?

      MCP::Prompt::Result.new(
        description: "Find #{item.truncate(80)} at Stanford Libraries",
        messages: [MCP::Prompt::Message.new(role: "user", content: MCP::Content::Text.new(lines.join("\n")))]
      )
    end

    def self.clean_argument(value)
      SearchworksMcp.sanitize_output(value.to_s).squish.truncate(MAX_ARGUMENT_LENGTH)
    end
  end
end
