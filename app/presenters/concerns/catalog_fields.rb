# frozen_string_literal: true

module CatalogFields
  def display_type(*, **) = nil

  def document_format
    document.document_formats.first
  end

  def main_title_date
    return unless document.key? 'pub_year_ss'

    year = document.first('pub_year_ss')

    if year.match?(/\d+u+/)
      value = year.gsub(/\d+u+/) do |match|
        "#{match.tr('u', '0')}s"
      end

      "(#{value})"
    else
      "(#{year})"
    end
  end

  delegate :eds_ris_export?, to: :document
end
