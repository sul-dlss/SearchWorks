# frozen_string_literal: true

module Articles
  class IndexBriefComponent < Record::IndexBriefComponent
    def container_classes
      classes = "brief-document container-fluid"
      classes += " eds-restricted" if eds_restricted?
      classes
    end

    delegate :eds_restricted?, to: :document
  end
end
