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

require File.join(File.dirname(__FILE__), 'api_file_monitor.rb')

#class FileMonitor < EarthPlugin
class FileMonitor
  
  def initialize
    @APIFileMonitor = ApiFileMonitor.new
    @APIFileMonitor.status_info = "Starting up"
  end
  
  def logger=(logger)
    @APIFileMonitor.logger = logger
  end

  def logger
    @APIFileMonitor.logger || RAILS_DEFAULT_LOGGER
  end

  def log_all_sql=(log_all_sql)
    @APIFileMonitor.log_all_sql = log_all_sql
  end
  
  def log_all_sql
    @APIFileMonitor.log_all_sql
  end
  
  def console_writer=(console_writer)
    @APIFileMonitor.console_writer = console_writer
  end
  
  def console_writer
    @APIFileMonitor.console_writer
  end
  
  def status_info=(status_info)
    @APIFileMonitor.status_info = status_info
  end
  
  def status_info
    @APIFileMonitor.status_info
  end
  
  def self.plugin_name
    "EarthFileMonitor"
  end

  def self.plugin_version
    131
  end
  
    # TODO: Check that paths are not overlapping
  def iteration(cache, only_initial_update = false, force_update_time = nil)
    @APIFileMonitor.iteration(cache, only_initial_update, force_update_time)
  end
  
  def directory_saved(node)
    @APIFileMonitor.directory_saved(node)
  end
  
  # Remove all directories on this server from the database
  def database_cleanup
    @APIFileMonitor.database_cleanup
  end

  def update(directories, update_time = 0, *args)
    @APIFileMonitor.update(directories, update_time, args)
  end
end
