$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

def reload_godaddy_reseller!
  Object.class_eval { remove_const :GoDaddyReseller  } if defined? GoDaddyReseller 
  require File.join(File.dirname(__FILE__),'../lib/godaddy_reseller')
end

require 'godaddy_reseller'
