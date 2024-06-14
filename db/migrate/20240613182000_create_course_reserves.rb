# -*- encoding : utf-8 -*-
class CreateCourseReserves < ActiveRecord::Migration[5.0]
  def self.up
    create_table :course_reserves do |t|
      t.string :id,              null: false, default: ""
      t.string :name
      t.string :course_number
      t.text :instructors 

      t.timestamps
    end

    add_index :course_reserves, :id,                unique: true
  end

  def self.down
    drop_table :course_reserves
  end
end
