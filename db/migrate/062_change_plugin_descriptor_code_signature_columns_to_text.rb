class ChangePluginDescriptorCodeSignatureColumnsToText < ActiveRecord::Migration
  def self.up
    change_column :plugin_descriptors, :code, :text
    change_column :plugin_descriptors, :sha1_signature, :text
  end

  def self.down
    change_column :plugin_descriptors, :code, :binary
    change_column :plugin_descriptors, :sha1_signature, :binary
  end
end