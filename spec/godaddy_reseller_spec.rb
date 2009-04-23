require File.dirname(__FILE__) + '/spec_helper'

describe GoDaddyReseller::API do

  before(:each) do
  end
  
  
  describe "::Connection" do
    
    it "decodes sample login response" do
      result = GoDaddyReseller::Connection.decode("<response c1TRID=\"reseller.0000000001\"><result code=\"1000\"><msg>login succeeded</msg></result><resdata><cid>58</cid><since>07/29/2003 12:14:55</since><timeout>300000</timeout></resdata></response>")
      result["result"]["code"].should == "1000"
    end
    
    it "creates correct xml for hash" do
      result = GoDaddyReseller::Connection.xml_encode_hash( :login => { :_attributes => { :msgDelimiter => '' }, :id => 'test-id', :pwd => 'test-pw'} )
      result.should == '<login msgDelimiter=""><id>test-id</id><pwd>test-pw</pwd></login>'
    end
    
    it "creates correct xml for hash of domains array" do
      result = GoDaddyReseller::Connection.xml_encode_hash({ :check => { :domain => ['example.com', 'example.net', 'example.org', 'example.info', 'example.biz', 'example.ws', 'example.us'].map { |d| {:_attributes => { :name => d }}} }})
      result.should == '<check><domain name="example.com" /><domain name="example.net" /><domain name="example.org" /><domain name="example.info" /><domain name="example.biz" /><domain name="example.ws" /><domain name="example.us" /></check>'
    end
    
    it "wraps xml correctly for hash" do
      result = GoDaddyReseller::Connection.wrap_with_header_xml(GoDaddyReseller::Connection.xml_encode_hash(:login => { :_attributes => { :msgDelimiter => '' }, :id => 'test-id', :pwd => 'test-pw'}))
      result.should == '<?xml version="1.0"?><wapi c1TRID="'+GoDaddyReseller::API.last_uid+'"><login msgDelimiter=""><id>test-id</id><pwd>test-pw</pwd></login></wapi>'
    end
    
    # it "authenticates and unauthenticates" do
    #   tda = GoDaddyReseller ::API.new('TRST', '0.0.1', 'apitest1', 'api1tda')
    #   tda.authenticate.should == true
    #   tda.logged_in?.should == true
    #   tda.unauthenticate.should == true
    #   tda.logged_in?.should == false
    #   tda.account.should be_nil
    # end
    # 
    # it "authenticates with correct login and gets account info" do
    #   tda = GoDaddyReseller ::API.new('TRST', '0.0.1', 'apitest1', 'api1tda')
    #   tda.authenticate.should == true
    #   tda.logged_in?.should == true
    #   tda.account.is_a?(Hash).should == true
    #   
    #   tda.unauthenticate # be nice
    # end
    # 
    # it "authenticates and keeps alive" do
    #   tda = GoDaddyReseller ::API.new('TRST', '0.0.1', 'apitest1', 'api1tda')
    #   tda.authenticate.should == true
    #   tda.logged_in?.should == true
    #   tda.keep_alive.should == true
    #   tda.logged_in?.should == true
    #   tda.account.is_a?(Hash).should == true
    #   
    #   tda.unauthenticate # be nice
    # end
    # 
    # 
    # it "fails incorrect login" do
    #   tda = GoDaddyReseller ::API.new('TRST', '0.0.1', 'badacct', 'badpw')
    #   tda.authenticate.should == false
    #   tda.logged_in?.should == false
    #   tda.account.should be_nil
    #   
    #   tda.unauthenticate # be nice
    # end
  
  end

end