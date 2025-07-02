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
      case @document.display_type
      when /^marc/
        render Record::MarcDocumentComponent.new(document: @presenter, **@kwargs)
      when /^mods/
        render Record::ModsDocumentComponent.new(document: @presenter, **@kwargs)
      else
        raise "Unknown display type #{@document.display_type}"
      end
    end
  end
end
