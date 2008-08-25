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

module EapiUtilities

  class EtaPrinter
    def initialize(file_name, description, number_of_items)
      @file_name = file_name
      @description = description
      @number_of_items = number_of_items
      @items_completed = 0
      @last_eta_update = 0
      @min_eta_update_delta = 1.seconds
      @start = Time.new
      @eta_string = ""
    end

    def increment()
      @items_completed += 1
      now = Time.new
      time_per_item = (now - @start) / @items_completed
      items_remaining = @number_of_items - @items_completed
      if items_remaining > 0
        if @last_eta_update.to_i + @min_eta_update_delta <= now.to_i
          @last_eta_update = now
          time_remaining = items_remaining * time_per_item
          @eta_string = "#{@description} [#{@items_completed}/#{@number_of_items}] ETA: #{(Time.local(2007) + (time_remaining)).strftime('%H:%M:%S')}s"
          @file_name.status_info = @eta_string
        end
      end
    end

    def etaString
      @eta_string
    end

  end

end
