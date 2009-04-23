module GoDaddyReseller 
  # Example Usage:
  # gdr.authenticate # authenticates on the server
  # gdr.account # returns the connection detials
  module Authentication
    def self.included(base) # :nodoc:
      base.class_eval do
        attr_accessor :user_id, :password, :logged_in, :account, :timeout_at
      end
    end
    
    def credentials(userid, pw)
      self.user_id = userid
      self.password = pw
    end
    
    def creds
      c.class.credentials_hash(user_id, password)
    end
    
    def authenticate
      self.account = describe
      self.timeout_at = Time.now + self.account['timeout'].to_i
      true
    rescue GoDaddyResellerError => e
      clear_login_data
    end
    
    protected
      # clears all pertainant login data, and returns false (for chaining or returning)
      def clear_login_data
        self.account = nil
        self.timeout_at = nil
        self.logged_in = false
      end
  end
end