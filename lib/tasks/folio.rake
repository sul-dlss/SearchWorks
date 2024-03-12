# frozen_string_literal: true

namespace :folio do
  task update_types_cache: :environment do
    Folio::Types.instance.sync!
  end
end
