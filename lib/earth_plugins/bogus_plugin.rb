require File.join(File.dirname(__FILE__), '..', 'earth_api', 'eapi_utilities.rb')

class BogusPlugin
   #include EapiUtilities
   
   # required for all plugins
   @status_info = "Mr Bogus is waking up..."
   @logger = nil
   
   def status_info
      @status_info
   end
   
   def status_info=(status_string)
      @status_info = status_string
   end
   
   def self.plugin_name
      "EarthBogusPlugin"
   end

   def self.plugin_version
      007
   end
   
   def logger=(logger)
      @logger = logger
   end
   
   def logger
      @logger || RAILS_DEFAULT_LOGGER
   end
   
   # Plugin's own content   
   def initialize
      @ETAPrinter = EapiUtilities::EtaPrinter.new(self, "Bogus Plugin printing some jibberish here. Teehee!", 2);
   end
      
   def doWork
      @ETAPrinter.increment;
      @logger.debug("Mr Bogus... he is the hero!!");
      @logger.debug(@ETAPrinter.etaString);
   end
end