# These are the raw api functions, for which you have to send pretty raw hashes.
#
# * Implemented:
# ** ProcessRequest: Provide support for calling WWD services using legacy WAPI request XMLs.
# ** CheckAvailability: Checks the availability of domains, hosts and name servers.
# ** Describe: Returns activity timeout and version information from the server.
# ** Info: Gets information about items that have been previously ordered.
# ** Poll: Used to retrieve status notifications about pending orders.
# ** OrderDomains: Used for registering new domain names.
# ** OrderDomainPrivacy: Used for adding privacy to a domain registration.
# ** OrderDomainTransfers: Used for transfering ownership of a domain from one user to another.
# ** OrderDomainRenewals: Used for renewing registration for existing public domain names.
# ** OrderPrivateDomainRenewals: Used for renewing registration for existing private domain names.
#
# * TODO Still requiring implementation:
# ** Cancel: Used for cancelling existing resources.
# ** CheckUser: Used for checking whether the account information for the specified user is valid or not.
# ** CreateNewShopper: Used for creating a new reseller sub-account.
# ** DomainForwarding: This method is used for forwarding a domain to a specified URL.
# ** GetDomainAlertCredits: Used for querying the number of domain alert, private backorder, and backorder credits.
# ** GetExpiringNameList: This method is used to get the list of expiring domain names for users that have an Investors Edge subscription.
# ** GetMonitoredDomainList: Used for querying a list of monitored domains.
# ** ManageTransfer: This method is used for managing the transfer of domains.
# ** ModifyDNS: This method is used for modifying DNS settings for a given domain.
# ** NameGen: Used to get the list of alternative domain names based on a given name.
# ** NameGenDB: Used to get the list of alternative domain names based on a given name (Domains Bot Service).
# ** NameGenDBWithTimeLimit: Used to get the list of alternative domain names based on a given name (Domains Bot Service).
# ** OrderCredits: Used to place an order on items that do not require customization (non-domain).
# ** OrderDomainBackOrders: Used for back ordering an existing (public or private) domain name.
# ** OrderResourceRenewals: Used for renewing non-domain items.
# ** RemoveDomainAlert: Used for removing an existing domain alert record.
# ** ResetPassword: Used for resetting the user's password in the WWD system.
# ** SetDomainLocking: This method is used for setting or clearing the lock on a list of domains.
# ** SetShopperInfo: Used for allowing the reseller to modify the user information for either their top-level account or any of its sub-accounts.
# ** SetupDomainAlert: Used for setting domain alert credit or backorder a domain.
# ** UpdateDomainAlert: Used for updating an existing domain alert record.
# ** UpdateDomainContact: This method is used for modifying associated contact information for the given domains.
# ** UpdateDomainForwarding: This method is used for performing multiple domain forwarding.
# ** UpdateDomainMasking: This method is used for performing multiple domain masking.
# ** UpdateDomainOwnership: Used for changing the ownership of a resource from one end user to another (both must be end-users of the currently logged in reseller).
# ** UpdateNameServer: This method is used for modifying associated name servers for the given domains.
# ** ValidateRegistration: This method is used for validating a domain's period and contacts.
module GoDaddyReseller 
  module WAPI
    
    def self.included(base) # :nodoc:
      base.class_eval do
        attr_accessor :orders, :polls, :manages
      end
    end
    
    # Runs the legacy ProcessRequest Command.
    def process_request(legacy_xml_or_hash)
      c.soap(:ProcessRequest, { 
        :ProcessRequest => { 
          :_attributes => { :xmlns => 'http://wildwestdomains.com/webservices/' },
          :sRequestXML => 
            c.class.escape_html(
              "<wapi clTRID='#{GoDaddyReseller::API.next_uid[0..50]}'" + 
              " account='#{user_id}' pwd='#{password}'>" +
              "#{legacy_xml_or_hash.is_a?(Hash) ? c.class.xml_encode_hash(legacy_xml_or_hash) : legacy_xml_or_hash.to_s}" +
              "</wapi>"
            )
          }
        }
      )
    end
    
    # Tests credentials, and returns the 'resdata' node if ok.  Otherwise, raises GoDaddyResellerError
    def describe
      response = c.soap(:Describe, 
        { :Describe => 
          { :_attributes => 
            { :xmlns => 'http://wildwestdomains.com/webservices/' }}.update(creds).update(c.class.uuid_hash) }
      )
      result = c.class.decode_soap(response.body)
      if result['result']['code'] == '1000'
        return result['resdata']
      else
        raise(GoDaddyResellerError.new(result['result']['msg']))
      end
    end
    
    # Executes the call to see if the domains provided are available, returning a hash with true, false, or :error
    def check_availability(domains_array)
      response = c.soap(:CheckAvailability, { 
        :CheckAvailability => { 
          :_attributes => { :xmlns => 'http://wildwestdomains.com/webservices/' },
          :sDomainArray => { :string => domains_array }
        }.update(creds).update(c.class.uuid_hash) }
      )
      result = c.class.decode_soap(response.body)
      if result['result'].nil?
        return GoDaddyReseller::WAPI::Util.check_result_to_answer(result)
      else
        raise(GoDaddyResellerError.new(result['result']['msg']))
      end
    end

    # This takes quite the hash. See spec/domains_spec.rb for example order_hashes
    # Returns an order response hash {:user_id => '2', :dbpuser_id => '3', :orderid => '100' }, 
    # or raises an error if there was a problem.
    # The order is also saved in self.orders for later retrieval.
    def order_domains(order_hash)
      _wapi_order(:OrderDomains, order_hash)
    end
    
    def order_domain_privacy(order_hash)
      _wapi_order(:OrderDomainPrivacy, order_hash)
    end
    
    # Used for renewing registration for existing public domain names.
    def order_domain_renewals(order_hash)
      _wapi_order(:OrderDomainRenewals, order_hash)
    end
    
    # Used for renewing registration for existing private domain names. Public domain names can be renewed at the same time
    def order_private_domain_renewals(order_hash)
      _wapi_order(:OrderPrivateDomainRenewals, order_hash)
    end
    
    # Used for transfering ownership of a domain from one user to another.
    def order_domain_transfers(order_hash)
      _wapi_order(:OrderDomainTransfers, order_hash)
    end

    
    # Requests all orders from the reseller server, and returns an array of hashes, containing one ore more orders, 
    # each with items
    # [ { :orderid => '100', :items => [ { :resourceid => 'domain:1', :statuses => [{ :id => '1', :timestamp =>  }] } ] }]
    def poll
      response = c.soap(:Poll, { 
        :Poll => { 
          :_attributes => { :xmlns => 'http://wildwestdomains.com/webservices/' }
        }.update(creds).update(c.class.uuid_hash) }
      )
      
      result = c.class.decode_soap(response.body)
      if result['result']['code'] == '1003' || result['result']['code'] == '1004'
        self.polls ||= []
        self.polls << GoDaddyReseller::WAPI::Util.poll_result_to_order_hash(result)
        return self.polls.last
      else
        raise(GoDaddyResellerError.new(result['result']['msg']))
      end
    end
    
    def info_by_domain_name(domain_name, type = "standard")
      _wapi_info({ :sDomain => domain_name }, type)
    end
    
    def info_by_resource_id(resource_id, type = "standard")
      _wapi_info({ :sResourceID => resource_id }, type)
    end

    
    
    
    # # Convenience method on top of the manage api call, for cancelling an item
    # def cancel(resourceid, type = 'deferred')
    #   manage(:manage => { :cancel => { 
    #     :_attributes => { :type => type },
    #     :id => resourceid
    #   }})
    # end
    # 
    # # Takes a setting for whether or not the domain should be locked (boolean), and sends the request to mark the
    # # domain as such. Returns the response message, or raises an error if there was a problem.
    # def modify_lock(locked, resourceid, manager_transaction_id)
    #   keep_alive!
    #   
    #   manage_hash = { :manage => { :setLocking => { 
    #     :_attributes => { :lock => (locked ? :yes : :no) }, 
    #     :domain => { :resourceid => resourceid, :mngTRID => manager_transaction_id } 
    #   }}}
    #   
    #   response = c.post("/manage/domains/setLocking", manage_hash)
    #   result = c.class.decode(response.body)
    #   if result['result']['code'] == '1000'
    #     self.manages ||= []
    #     self.manages << result['resdata']
    #     return self.manages.last
    #   else
    #     raise(GoDaddyResellerError.new(result['result']['msg']))
    #   end
    # end
    # 
    # # This takes quite the hash. See spec/domains_spec.rb for example manage_hashes
    # # Returns the response message, or raises an error if there was a problem.
    # def manage(manage_hash)
    #   keep_alive!
    #   
    #   response = c.post("/Manage", manage_hash)
    #   result = c.class.decode(response.body)
    #   if result['result']['code'] == '1000'
    #     self.manages ||= []
    #     self.manages << result['resdata']
    #     return self.manages.last
    #   else
    #     raise(GoDaddyResellerError.new(result['result']['msg']))
    #   end
    # end
    # 
    # # Calls the alternate name generation server, and returns the raw array it returns.  The docs didn't really describe it very well.
    # def alternate_domains(name_without_tld, options = {})
    #   keep_alive!
    #   
    #   response = c.post("/nameGenDB", { :nameGenDB => { :_attributes => { :key => name_without_tld}.merge(options) }})
    #   result = c.class.decode(response.body)
    #   if result['result']['code'] == '1000'
    #     result['resdata'].values.detect{ |v| v.is_a?(Array) } || []
    #   else
    #     raise(GoDaddyResellerError.new(result['result']['msg']))
    #   end
    # end
    # alias_method :name_gen_db, :alternate_domains

    
    protected
    
      # Generic order method, which can handle sending an order, and decoding an order
      def _wapi_order(order_type_sym, order_hash)
        response = c.soap(order_type_sym, { 
          order_type_sym => { 
            :_attributes => { :xmlns => 'http://wildwestdomains.com/webservices/' }
          }.update(order_hash).update(creds).update(c.class.uuid_hash) }
        )
    
        result = c.class.decode_soap(response.body)
        if result['result']['code'] == '1000'
          self.orders ||= []
          self.orders << { :user_id => result['user'], :dbpuser_id => result['dbpuser'], :orderid => result['resdata']['orderid'] }
          return self.orders.last
        else
          raise(GoDaddyResellerError.new(result['result']['msg']))
        end
      end
      
      
      # Checks the information for the info_hash. 
      # There are several helper functions built on top of this, like info_by_domain_name and info_by_resource_id
      # Returns a hash with information for each. 
      # { 'example.com' =>  {:resourceid, :autoRenewDate, :ownerID, :expirationDate, :status, :private }} 
      def _wapi_info(info_hash, type = "standard")
        response = c.soap(:Info, { 
          :Info => { 
            :_attributes => { :xmlns => 'http://wildwestdomains.com/webservices/' },
            :sType => type
          }.update(info_hash).update(creds).update(c.class.uuid_hash) }
        )

        result = c.class.decode_soap(response.body)
        if result['result']['code'] == '1000'
          GoDaddyReseller::WAPI::Util.info_result_to_hash(result)
        else
          raise(GoDaddyResellerError.new(result['result']['msg']))
        end
      end

  
  public
  
    module Util
    
      # Turns a result of a check request to a hash of domain names with true, false, or :error.  Broken out mostly to test it.
      def self.check_result_to_answer(result)
        answer = {}
        domain_results = result['domain'].is_a?(Hash) ? 
                              [ result['domain'] ] : result['domain']

        domain_results.each do |domain_hash|
          answer[domain_hash['name'].to_s] = case domain_hash['avail'].to_s
          when '0'
            false
          when '1'
            true
          when '-1'
            :error
          end
        end
      
        answer
      end
    
      # Turns a result of a info request to a hash of domain names with all necessary values.  Broken out mostly to test it.
      # { 'example.com' =>  {:resourceid, :autoRenewDate, :ownerID, :expirationDate, :status, :private }}
      def self.info_result_to_hash(result)
        hash = {}
      
        domain_results = result['resdata']['info'].is_a?(Hash) ? 
                              [ result['resdata']['info'] ] : result['resdata']['info']
            
        domain_results.each do |domain_hash|
          domain_name = domain_hash.delete('name').to_s.downcase
          converted_hash = {}
          domain_hash.each_pair do |k,v|
            converted_hash[k.to_sym] = case k
            when 'auto_renew_date', 'create_date', 'expiration_date'
              v.blank? ? v : Time.parse(v)
            when 'private'
              v == 'yes' ? true : false
            when 'status'
              v.to_i
            else
              v
            end
          end

          hash[domain_name] = converted_hash
        end
      
        hash
      end
    
      # Turns a result of a check routine to an array of order hashes 
      # [ { :orderid => '100', :items => [ { :riid => '1', :resourceid => 'domain:1', :statuses => [{ :id => '1', :timestamp =>  }] } ] }].  
      # Broken out mostly to test it.
      def self.poll_result_to_order_hash(result)
        order_array = []
      
        item_results = result['resdata']['report']['item'].is_a?(Hash) ? 
                              [ result['resdata']['report']['item'] ] : result['resdata']['report']['item']
      
        item_results.each do |item_hash|
          order = order_array.detect {|o| o[:orderid] == item_hash['orderid'] }
          unless order
            order_array << { :orderid => item_hash['orderid'], :items => [] }
            order = order_array.last
          end
          order[:roid] = item_hash['roid'] unless item_hash['roid'].blank?
        
          item = order[:items].detect {|i| i[:riid] == item_hash['riid'] }
          unless item
            order[:items] << { :riid => item_hash['riid'], :statuses => [] }
            item = order[:items].last
          end
        
          item[:statuses] << { :id => item_hash['status'], :timestamp => Time.parse(item_hash['timestamp']) }
          item[:resourceid] = item_hash['resourceid'] unless item_hash['resourceid'].blank?
        end
      
        order_array
      end
    
      # Finds a specific riid in a specific order, from a poll result
      def self.find_by_riid_and_orderid_from_poll_result(riid, orderid, poll_result)
        poll_result.detect { |o| o[:orderid] == orderid.to_s }[:items].detect { |i| i[:riid] == riid.to_s } rescue nil
      end
    end
  end
end