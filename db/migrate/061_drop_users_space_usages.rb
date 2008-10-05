class DropUsersSpaceUsages < ActiveRecord::Migration
  def self.up
    drop_table :users_space_usages
  end
  
  def self.down
    create_table (:users_space_usages, :force => true) do |t|
      t.integer :uid
      t.integer :server_id
      t.decimal :space_usage
    end
  end
end
