class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :eventtype_id
      t.float :value
      t.boolean :is_manual
      t.string :comment
      t.integer :user_id
      t.timestamp :event_time

      t.timestamps
    end
  end
end
