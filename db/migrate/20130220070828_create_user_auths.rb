class CreateUserAuths < ActiveRecord::Migration
  def change
    create_table :user_auths do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :auth_token

      t.timestamps
    end
    add_index :user_auths, :user_id
  end
end
