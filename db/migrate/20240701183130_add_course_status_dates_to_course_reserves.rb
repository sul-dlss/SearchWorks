class AddCourseStatusDatesToCourseReserves < ActiveRecord::Migration[7.1]
  def change
    add_column :course_reserves, :start_date, :datetime
    add_column :course_reserves, :end_date, :datetime
    add_column :course_reserves, :is_active, :boolean
  end
end
