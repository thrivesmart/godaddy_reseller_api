module GoDaddyReseller 
  module Domains
    
    # TODO
    # Orders the domain in the format second_level_domain.top_level_domain for num_years.
    #  That is, top_level_domain is without the period (e.g. :com, 'com' or 'COM')
    # 
    # If other_domain_or_contact_hash is a string, it copies the contact information from that domain.  Otherwise, it must be a hash in the form:
    #  {:fname => 'Joe',
    #  :lname => 'Smith',
    #  :email => 'joe@smith.us',
    #  :sa1 => '1 S. Main St.',
    #  :sa2 => [Optional string],
    #  :city => 'Oakland',
    #  :sp => 'California',
    #  :pc => '97123',
    #  :cc => 'United States',
    #  :phone => '(777)555-1212'
    #  :fax => [Optional string]}
    #
    # Optionally, if the name servers are passed in (in the format ['ns1.example.net', 'ns2.example.net']), it includes those in the order.
    #
    # Optionally, if the other_domain_or_contact_hash was a domain, other_domain_or_login_hash can be empty, and the same login credentials will be used.
    #   Otherwise, if other_domain_or_login_hash is a string, it copies the login information from that domain.
    #   Otherwise, if other_domain_or_login_hash is a hash with { :user => 'someid' }, it will register the domain for that user
    #   Otherwise, other_domain_or_login_hash must be a hash in the format: { :pwd => 'ghijk', :pwdhint => 'ghijk', :pin => '1234' }
    #  
    # def register_domain(second_level_domain, top_level_domain, num_years, other_domain_or_contact_hash, nameservers = [], other_domain_or_login_hash = nil)
    #   
    #   product_code = GoDaddyReseller::ProductTable.domain_reg_id(top_level_domain, num_years)
    #   
    #   other_contact_domain = other_domain_or_contact_hash.is_a?(String) ? info_by_domain_name([other_contact_domain]) : nil
    #   
    #   contact_info = if other_domain_or_contact_hash.is_a?(Hash)
    #     other_domain_or_contact_hash
    #   else
    #     other_contact_domain
    #   end
    #   
    #   login_info = if other_domain_or_contact_hash.nil?
    #     { :user => other_contact_domain[:owner_id] }
    #   elsif other_domain_or_contact_hash.is_a?(Hash)
    #     if other_domain_or_contact_hash.key?(:user)
    #       { :email => contact_info[:email], 
    #         :firstname => contact_info[:fname], 
    #         :lastname => contact_info[:lname], 
    #         :phone => contact_info[:phone] }.merge(other_domain_or_contact_hash)
    #     else
    #       { :email => contact_info[:email], 
    #         :firstname => contact_info[:fname], 
    #         :lastname => contact_info[:lname], 
    #         :phone => contact_info[:phone] }.merge(other_domain_or_contact_hash).merge(:user => 'createNew')
    #     end
    #   else
    #     { :user => info_by_domain_name([other_domain_or_contact_hash])[:owner_id] }
    #   end
    #   
    #   nexus =  top_level_domain.length == 2 ? 
    #       { :nexus => { :category => "citizen of #{top_level_domain.upcase}", :use => "personal", :country => "#{top_level_domain.upcase}" }} : 
    #       {}
    #   
    #   nsarray = nameservers.empty? ? {} : { :nsArray => { :NS =>  nameservers.map { |n| { :name => n }}}}
    #   
    #   order_domains({ 
    #     :shopper => login_info,
    #     :items => {
    #       :DomainRegistration => [
    #         { # 1 of 2: example.us
    #           :order => {
    #             :productid => product_code,
    #             :quantity => 1,
    #             :riid => 1,
    #             :duration => num_years
    #           },
    #           :sld => second_level_domain,
    #           :tld => top_level_domain,
    #           :period => num_years,
    #           :registrant => contact_info,
    #           :admin => contact_info,
    #           :billing => contact_info,
    #           :tech => contact_info,
    #           :autorenewflag => 1
    #         }.update(nexus).update(nsarray)
    #       ]
    #     }
    #   })
    # end
  end
end