# frozen_string_literal: true

class PageLocation
  def initialize(search_state)
    @search_state = search_state
  end

  def access_point
    return unless filters.present? &&
                  @search_state.controller.controller_name == 'catalog' &&
                  @search_state.controller.action_name == 'index'

    @access_point ||= case
                      when format_includes_databases?
                        :databases
                      when course_reserve_parameters?
                        :course_reserve
                      when sdr_parameters?
                        :sdr
                      when digital_collections_parameters?
                        :digital_collections
                      when dissertation_theses_parameters?
                        :dissertation_theses
                      when government_documents_parameters?
                        :government_documents
                      when iiif_resources_parameters?
                        :iiif_resources
                      else
                        ''
                      end

    @access_point.presence
  end

  def access_point?
    access_point.present?
  end

  def databases?
    access_point == :databases
  end

  def sdr?
    access_point == :sdr
  end

  def digital_collections?
    access_point == :digital_collections
  end

  def dissertation_theses?
    access_point == :dissertation_theses
  end

  def collection?
    collection_parameters?
  end

  private

  delegate :filter, :filters, to: :@search_state

  def format_includes_databases?
    filter(:format_hsim).include?('Database') || filter(:format_main_ssim).include?('Database')
  end

  def course_reserve_parameters?
    filter(:courses_folio_id_ssim).any?
  end

  def collection_parameters?
    filter(:collection).values.excluding('sirsi', 'folio').present?
  end

  def digital_collections_parameters?
    filter(:collection_type).include?('Digital Collection')
  end

  def sdr_parameters?
    filter(:library).include?('SDR')
  end

  def dissertation_theses_parameters?
    filter(:genre_ssim).include?('Thesis/Dissertation')
  end

  def bookplate_fund_parameters?
    filter(:fund_facet).any?
  end

  def government_documents_parameters?
    filter(:genre_ssim).include?('Government document')
  end

  def iiif_resources_parameters?
    filter(:iiif_resources).include?('available')
  end
end
