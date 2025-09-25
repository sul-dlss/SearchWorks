# frozen_string_literal: true

module Searchworks4
  class FindingAidLinkComponent < Searchworks4::LinkComponent
    def link_text
      safe_join([super, arrow_icon], ' ')
    end

    def link_attr
      super.merge(finding_aid_button_classes)
    end

    def finding_aid_button_classes
      if href&.include?('//archives.stanford.edu')
        { class: 'btn btn-sm py-0 btn-palo-alto' }
      else
        { class: 'btn btn-sm py-0 btn-outline-secondary' }
      end
    end

    def arrow_icon
      tag.i(class: 'bi bi-arrow-up-right ps-1', aria: { hidden: true })
    end
  end
end
