# frozen_string_literal: true

###
#  The Bookplate class deserializes a solr field representing a Bookplate
#  The expected format of that field is "FUND-NAME -|- DRUID -|- FILE-ID -|- BOOKPLATE-TEXT"
#  Example: "SHARPS -|- druid:rq470hm8269 -|- rq470hm8269_00_0001.jp2 -|- Susan and Ruth Sharp Fund"
###
class Bookplate
  attr_reader :bookplate_data

  include StacksImages

  def initialize(bookplate_data)
    @bookplate_data = bookplate_data
  end

  def thumbnail_url
    craft_image_url(druid:, image_id: file_id, size: :large)
  end

  def text
    split_fields[3]
  end

  def params_for_search
    { f: { facet_field_key.to_sym => [druid] } }
  end

  def to_partial_path
    'bookplates/bookplate'
  end

  def matches?(params)
    values = Array.wrap(params.dig(:f, facet_field_key.to_sym))

    values.include?(druid) || values.include?(fund_name)
  end

  private

  def fund_name
    split_fields[0]
  end

  def druid
    split_fields[1].gsub('druid:', '')
  end

  def file_id
    split_fields[2].gsub(/\..*$/, '')
  end

  def split_fields
    bookplate_data.split(data_delimiter).map(&:strip)
  end

  def facet_field_key
    :fund_facet
  end

  def data_delimiter
    '-|-'
  end
end
