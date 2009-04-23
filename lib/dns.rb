module GoDaddyReseller 
  module DNS
    
  #   def self.included(base) # :nodoc:
  #     base.class_eval do
  #       attr_accessor :dns_updates
  #     end
  #   end
  #   
  #   # Convenience method for adding a single dns record to a domain
  #   def add_dns_record(domain, record_type, record_value, time_to_live = nil, cname_key = nil)
  #     update_dns_records(domain, { 
  #       record_type.to_sym => { :_attributes => 
  #         { :action => :set, :recValue => record_value }.merge(
  #           cname_key ? {:key => cname_key} : {}
  #         ).merge(time_to_live ? {:ttl => time_to_live} : {}) 
  #       }
  #     })
  #   end
  #   
  #   # Convenience method for removing a single dns record to a domain
  #   def remove_dns_record(domain, record_type, record_value, cname_key = nil)
  #     update_dns_records(domain, { 
  #       record_type.to_sym => { :_attributes => { 
  #         :action => :remove, :recValue => record_value }.merge(cname_key ? {:key => cname_key} : {})
  #       }
  #     })
  #   end
  #   
  #   # Updates one or more dns records for a domain.  See add_dns_record for an example dns_records_hash
  #   def update_dns_records(domain, dns_records_hash)
  #     keep_alive!
  #     
  #     manage_hash = { :manage => { 
  #       :modifyDNS => { :_attributes => { :domain => domain } }.merge(dns_records_hash)
  #     }}
  #     
  #     response = c.post("/manage/domains/modifyNameServer", manage_hash)
  #     result = c.class.decode(response.body)
  #     if result['result']['code'] == '1000'
  #       self.dns_updates ||= []
  #       self.dns_updates << result['resdata']
  #       return self.dns_updates.last
  #     else
  #       raise(GoDaddyResellerError.new(result['result']['msg']))
  #     end
  #   end
  end
end
