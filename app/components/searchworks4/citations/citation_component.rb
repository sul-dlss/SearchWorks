# frozen_string_literal: true

module Searchworks4
  module Citations
    class CitationComponent < ViewComponent::Base
      attr_reader :presenter

      def initialize(presenter:)
        @presenter = presenter
        super
      end

      delegate :citations, :eds_ris_export?, to: :presenter
      delegate :refworks_export_url, to: :helpers

      def render?
        citations.present?
      end

      def exports_ris?
        presenter.document.export_formats.key?(:ris)
      end

      def exports_endnote?
        presenter.document.export_formats.key?(:endnote)
      end

      def exports_refworks?
        presenter.document.export_formats.key?(:refworks_marc_txt)
      end
    end
  end
end
