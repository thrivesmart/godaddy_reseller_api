require 'uuid'
require 'connection'
require 'authentication'
require 'util'
require 'product_table'
require 'domains'
require 'dns'
require 'wapi'
require 'certification'

# Example Usage:
# tda = GoDaddyReseller::API.new('apitest1', 'api1tda')
# If you need to override RAILS_ENV (for example, you have a production environment named something other than 'production'), use
# tda.set_testing_mode(false)
module GoDaddyReseller 
  class GoDaddyResellerError < StandardError; end

  class API
    include WAPI
    include Authentication
    include Domains
    include DNS
    include Certification
    
    TEST_API_HOST = 'https://api.ote.wildwestdomains.com/wswwdapi/wapi.asmx?WSDL'
    PRODUCTION_API_HOST = 'https://api.wildwestdomains.com/wswwdapi/wapi.asmx?wsdl'
    UID = UUID.new

    attr_accessor :connection
    
    def self.next_uid; @@last_uid = UID.generate end
    def self.last_uid; @@last_uid end
    
    # Setup the api with your source, version, and optionally a userid and password
    def initialize(userid = nil, pw = nil)
      self.connection = Connection.new
      set_testing_mode(RAILS_ENV != 'production')
      credentials(userid, pw) if userid && pw
    end
    
    # Sets connection to use test servers if testing_mode_on is true.  
    # Otherwise sets up connection to use production servers.
    def set_testing_mode(testing_mode_on = true)
      testing_mode_on ? c.site = TEST_API_HOST : c.site = PRODUCTION_API_HOST
    end
    
    # shorthand for connection
    def c; return connection ;end
  end

end