# frozen_string_literal: true

class HooverOpenUrlRequest
  include ActionView::Helpers::OutputSafetyHelper

  delegate :to_param, to: :as_params
  def initialize(library, document)
    @library = library
    @document = document
  end

  def to_url
    "#{base_url}&#{to_param}"
  end

  def as_params
    {
      'ItemInfo5' => record_url, 'ReferenceNumber' => ckey,
      'ItemTitle' => item_title, 'ItemAuthor' => item_author,
      'ItemDate' => item_date, 'ItemPublisher' => item_publisher,
      'ItemPlace' => item_place, 'ItemEdition' => item_edition,
      'ItemInfo2' => item_restrictions, 'ItemInfo3' => item_conditions,
      'Value' => request_type
    }.reject { |_, v| v.blank? }
  end

  def request_type
    'GenericRequestMonograph'
  end

  def record_url
    "https://searchworks.stanford.edu/view/#{ckey}"
  end

  def ckey
    document[:id]
  end

  def item_title
    marc_data(field_codes: '245', subfield_codes: %w[a b n p])
  end

  def item_author
    author_fields = {
      '100' => %w[a b c d q], '110' => %w[a b c d],
      '111' => %w[a c d],     '130' => %w[a d f n p]
    }

    author_fields.each do |field_codes, subfield_codes|
      data = marc_data(field_codes:, subfield_codes:)
      return data if data.present?
    end
    nil # return nil if none of the fields matched
  end

  def item_date
    marc_data(field_codes: '245', subfield_codes: ['f'])
  end

  def item_publisher
    marc_260 = marc_data(field_codes: '260', subfield_codes: %w[a b c])
    marc_264 = marc_data(field_codes: '264', subfield_codes: %w[a b c])
    safe_join([marc_260, marc_264], ' ')
  end

  def item_place
    marc_data(field_codes: '300', subfield_codes: %w[a b c f])
  end

  def item_edition
    marc_data(field_codes: '250', subfield_codes: ['a'])
  end

  def item_restrictions
    marc_data(field_codes: '506', subfield_codes: %w[3 a])
  end

  def item_conditions
    marc_data(field_codes: '540', subfield_codes: %w[3 a])
  end

  private

  attr_reader :library, :document

  def marc
    document.to_marc
  end

  def marc_data(field_codes:, subfield_codes:)
    field_code = marc_field_code_for_present_data(field_codes:, subfield_codes:)
    return unless field_code

    safe_join(marc[field_code].subfields.filter_map do |subfield|
      next unless subfield_codes.include?(subfield.code)

      subfield.value
    end, ' ')
  end

  def marc_field_code_for_present_data(field_codes:, subfield_codes:)
    Array.wrap(field_codes).find do |code|
      marc[code].present? && marc[code].subfields.any? { |subfield| subfield_codes.include?(subfield.code) }
    end
  end

  def base_url
    Settings.HOOVER_REQUESTS_URL
  end
end
