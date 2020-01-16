# frozen_string_literal: true

class AccessPanels
  class Exhibit < ::AccessPanel
    delegate :druid, to: :@document
    delegate :present?, to: :druid
  end
end
