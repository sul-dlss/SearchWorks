# frozen_string_literal: true

module Record
  class MarcContentAdviceComponentPreview < Lookbook::Preview
    layout 'lookbook'

    def advice
      document = SolrDocument.from_fixture("14289604.yml")
      render Record::MarcContentAdviceComponent.new(document: document)
    end
  end
end
