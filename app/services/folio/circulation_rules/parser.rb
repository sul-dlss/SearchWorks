# frozen_string_literal: true

module Folio
  module CirculationRules
    # A parser for FOLIO circulation rules files
    # See: https://github.com/folio-org/mod-circulation/blob/master/doc/circulationrules.md
    class Parser < Parslet::Parser
      rule(:line_comment) { ws? >> (str('#') | str('/')) >> match('[^\n]').repeat(0) >> newline }
      rule(:newline) { (ws? >> str("\n")).repeat(1) }
      rule(:newline?) { (ws? >> str("\n")).repeat(0) }
      rule(:ws?) { match(' ').repeat(0) }
      rule(:name) { match('[0-9a-zA-Z>-]').repeat(1) }

      rule(:file) { newline? >> (headers >> newline).repeat(0).as(:headers) >> newline? >> statement.repeat(0).as(:statement) }
      rule(:headers) { priority_stanza | fallback_stanza }
      rule(:priority_stanza) { str('priority') >> ws? >> str(':') >> ws? >> (priority >> ws? >> str(',').maybe >> ws?).repeat(0).as(:priority) }
      rule(:fallback_stanza) { str('fallback-policy') >> ws? >> str(':') >> ws? >> policies.as(:fallback) }

      rule(:priority) do
        (str('first-line') | str('last-line') | str('number-of-criteria') | criteriumPriority | sevenCriteriumLetters).as(:criterium)
      end
      rule(:criteriumPriority) { (str('criterium') >> ws? >> str('(') >> ws? >> sevenCriteriumLetters >> ws? >> str(')')) }
      rule(:sevenCriteriumLetters) { criterium_letter >> (criterium_letter | match('[, ]')).repeat(0) }
      rule(:criterium_letter) { match('[tabcsmg]').as(:letter) }

      # indent = number of spaces the rule was indented in the export file
      # note that this is not the same as the indentation level in the rule tree
      # one indentation level in the export file is 4 spaces (a tab)
      rule(:indent) { str(' ').repeat(0).maybe.as(:indent) }
      rule(:statement) { line_comment | (indent >> criteria >> (ws? >> str(':') >> ws? >> policies).maybe >> newline) }
      rule(:criteria) { criterium.as(:criterium) >> (ws? >> str('+') >> ws? >> criterium).repeat(0).as(:addl_criterium) }

      rule(:criterium) do
        criterium_letter >> ws? >> (
          str('all').as(:any) |
            (name.as(:uuid) >> ws?).repeat(1).as(:or) |
            (str('!') >> ws? >> name.as(:uuid) >> ws?).repeat(1).as(:or).as(:not)
        ).as(:criterium_value)
      end

      rule(:policies) { (policy >> ws?).repeat(0).as(:policy) }
      rule(:policy) { (match('[a-z]').as(:type) >> ws? >> name.as(:uuid)) }

      root(:file)
    end
  end
end
