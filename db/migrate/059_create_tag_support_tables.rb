class CreateTagSupportTables < ActiveRecord::Migration
  def self.up
    
    create_table :tag do |t|
      t.column :key, :string, :null => false  #Category of the tag. Eg: inbox, trash...
      t.column :value, :string, :null => false  #The name of the tag given by the user
    end

    create_table :file_tag, :id => false do |t|
      t.column :file_id, :integer, :null => false
      t.column :tag_id,  :integer, :null => false
      t.foreign_key :file_id, :files,:id #, { :on_delete => :cascade, :name => "cached_sizes_directories_id_fk"  }
      t.foreign_key :tag_id,  :tag , :id #, { :on_delete => :cascade, :name => "cached_sizes_filters_id_fk" }
    end
   
  end
  
  def self.down
    drop_table :tag
    drop_table :filetag
  end  
end

