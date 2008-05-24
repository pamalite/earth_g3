# Add a new columns 'sequence', 'job' and 'shot' to table files
# for tag support for RSP name convention
class AddRspTagToFiles < ActiveRecord::Migration
  def self.up
    add_column :files, :sequence, :string 
    add_column :files, :job     , :string 
    add_column :files, :shot    , :string  
  end

  def self.down
    remove_column :files, :sequence
    remove_column :files, :job
    remove_column :files, :shot
  end
end
