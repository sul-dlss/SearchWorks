# frozen_string_literal: true

namespace :folio do
  task update_courses_db: :environment do
    # These are read to the database so are different from all the others
    Folio::Courses.instance.sync_courses!
  end
end
