# frozen_string_literal: true

module Record
  class DocumentComponent < ViewComponent::Base
    def initialize(presenter: nil, document: nil, **kwargs)
      @presenter = presenter
      @document = document || presenter.document
      @kwargs = kwargs
      super
    end

    def call
      if @document.mods?
        render Record::ModsDocumentComponent.new(document: @presenter, **@kwargs)
      else
        render Record::MarcDocumentComponent.new(document: @presenter, **@kwargs)
      end
    end
  end
end
