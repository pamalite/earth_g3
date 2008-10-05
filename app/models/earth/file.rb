# Copyright (C) 2007 Rising Sun Pictures and Matthew Landauer
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

module Earth
  class File < ActiveRecord::Base
    belongs_to :directory
    composed_of :user, :mapping => [%w(uid uid)]
    
    Stat = Struct.new(:mtime, :size, :blocks, :uid, :gid)
    class Stat
      def ==(s)
        mtime == s.mtime && size == s.size && blocks == s.blocks && uid == s.uid && gid == s.gid
      end
    end
    
    # Convenience method for setting all the fields associated with stat in one hit
    def stat=(stat)
      self.modified = stat.mtime.utc
      self.bytes = stat.size
      self.blocks = stat.blocks
      self.uid = stat.uid
      self.gid = stat.gid
    end
    
    # Returns a "fake" Stat object with some of the same information as File::Stat
    def stat
      Stat.new(modified, bytes, blocks, uid, gid)
    end
    
    def size
      Size.new(bytes, blocks, 1)
    end
    
    def empty?
      bytes == 0
    end
    
    def hidden?
      name && name[0] == ?.
    end
    
    def self.filter(files,options={})
      show_hidden = options[:show_hidden]
      
      any_empty  = false
      any_hidden = false
      
      filtered = files.map do |file|
        any_empty  = true if file.empty?
        any_hidden = true if file.hidden?
        
        file if show_hidden || !file.hidden?
      end
      
      [filtered.compact, any_empty, any_hidden]
    end

    def path
      File.join(directory.path, name)
    end
    
    def self.build_filter_conditions(params)
      filter_filename = params[:filter_filename]
      filter_filename = "*" if filter_filename.blank?

      # JON - support for job 
      filter_job = params[:filter_job]
      filter_job = "*" if filter_job.blank?
      # JON - end 

      # JON - support for sequence 
      filter_sequence = params[:filter_sequence]
      filter_sequence = "*" if filter_sequence.blank?
      # JON - end 

      # JON - support for shot 
      filter_shot = params[:filter_shot]
      filter_shot = "*" if filter_shot.blank?
      # JON - end 
      
      filter_user = params[:filter_user]
      filter_uid  = filter_user.blank? ? nil : User.find_by_name(filter_user).uid

      if filter_uid
        ["files.name LIKE ? AND files.uid = ?", filter_filename.tr('*', '%'), filter_uid]
      elsif filter_filename != '*'
        ["files.name LIKE ?", filter_filename.tr('*', '%')]
      # JON - search files using tags
      # search files through job , sequence and shot
      elsif filter_job != '*' && filter_sequence != '*' && filter_shot != '*'
        ["files.job LIKE ? AND files.sequence LIKE ? AND files.shot LIKE ?", filter_job.tr('*', '%'), filter_sequence.tr('*', '%'), filter_shot.tr('*', '%')]
      # search files through job and sequence
      elsif filter_job != '*' && filter_sequence != '*'
        ["files.job LIKE ? AND files.sequence LIKE ?", filter_job.tr('*', '%'), filter_sequence.tr('*', '%')]
      # search files through shot and sequence
      elsif filter_shot != '*' && filter_sequence != '*'
        ["files.shot LIKE ? AND files.sequence LIKE ?", filter_shot.tr('*', '%'), filter_sequence.tr('*', '%')]
      # search files through job and shot
      elsif filter_job != '*' && filter_shot != '*'
        ["files.job LIKE ? AND files.shot LIKE ?", filter_job.tr('*', '%'), filter_shot.tr('*', '%')]
      # search files through job
      elsif filter_job != '*'
        ["files.job LIKE ?", filter_job.tr('*', '%')]
      # search files through sequence
      elsif filter_sequence != '*'
        ["files.sequence LIKE ?", filter_sequence.tr('*', '%')]
      # search files through shot
      elsif filter_shot != '*'
        ["files.shot LIKE ?", filter_shot.tr('*', '%')]
      # JON - end 
      end
    end
    
    def self.with_filter(params = {})
      filter_conditions = build_filter_conditions(params)

      Thread.current[:with_filtering] = filter_conditions
      
      Earth::File.with_scope(:find => {:conditions => filter_conditions}) do
        begin
          yield
        ensure
          Thread.current[:with_filtering] = nil
        end
      end
    end
  end
end
