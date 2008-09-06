   class ApiEtaPrinter
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
