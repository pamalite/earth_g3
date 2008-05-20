# Add a new columns 'sequence', 'job' and 'shot' to table files
# for tag support for RSP name convention
class AddRspTagToFiles < ActiveRecord::Migration
  def self.up
    add_column :files, :sequence, :string # :null => true or should be set to false ?
    add_column :files, :job     , :string # :null => true or should be set to false ?
  # add_column :files, :shot    , :string # :null => true or should be set to false ?
  # not used as 'shot' is the same than file 'name' 
  end

  def self.down
    remove_column :files, :sequence
    remove_column :files, :job
  # remove_column :files, shot
  # see 'def self.up'
  end
end
