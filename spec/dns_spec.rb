require File.dirname(__FILE__) + '/spec_helper'

describe GoDaddyReseller::DNS do

  before(:each) do
  end

  it "creates add xml correctly" do 
    result = GoDaddyReseller::Connection.xml_encode_hash(
      { :manage => { 
        :modifyDNS => { 
          :_attributes => { :domain => 'example.com' },
          :cname => [
            { :_attributes => {:action => :set, :recVal => 'subdomain.example.com', :key => '1' } }, 
            { :_attributes => {:action => :remove, :recVal => 'old.example.com', :key => '2' } }],
          :a => { :_attributes => {:action => :set, :recVal => '127.0.0.1' } },
          :mx => [
            { :_attributes => {:action => :set, :recVal => '0 mail.example.com' } }, 
            { :_attributes => {:action => :set, :recVal => '5 mail2.example.com' } }],
        }
      }}
    )
    expected = '<manage><modifyDNS domain="example.com"><a action="set" recVal="127.0.0.1" /><cname action="set" key="1" recVal="subdomain.example.com" /><cname action="remove" key="2" recVal="old.example.com" /><mx action="set" recVal="0 mail.example.com" /><mx action="set" recVal="5 mail2.example.com" /></modifyDNS></manage>'
    
    result.should == expected
  end


end