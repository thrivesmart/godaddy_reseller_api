require File.dirname(__FILE__) + '/spec_helper'

describe GoDaddyReseller::Domains do

  before(:each) do
  end

  it "decodes a sample check response correctly" do
    response = '<response c1TRID="reseller.0000000003"><result code="1000"/><resdata><check><domain name="example.com" avail="0" /><domain name="example.net" avail="0" /><domain name="example.org" avail="1"/><domain name="example.info" avail="-1" /><domain name="example.biz" avail="0" /><domain name="example.ws" avail="1" /><domain name="example.us" avail="1" /></check></resdata></response>'
    result = GoDaddyReseller::Connection.decode(response)
    answer = GoDaddyReseller::Domains.check_result_to_answer(result)
    answer.should == { 'example.com' => false, 
                       'example.net' => false, 
                       'example.org' => true, 
                       'example.info' => :error, 
                       'example.biz' => false, 
                       'example.ws' => true, 
                       'example.us' => true }
  end
  
  it "creates poll xml correctly" do
    result = GoDaddyReseller::Connection.xml_encode_hash(:poll => { :_attributes => { :op => 'req'}})
    
    result.should == '<poll op="req" />'
  end

  it "decodes a sample info response correctly" do
    response = '<response clTRID="reseller.0000000007"><result code="1000"/><resdata><info resourceid="domain:1" autoRenewDate="7/28/2005 4:59:59 PM" name="EXAMPLE.COM" ownerID="1" expirationDate="7/28/2005 4:59:59 PM" status="0" private="yes"/><info resourceid="domain:2" autoRenewDate="7/28/2005 4:59:59 PM" name="EXAMPLE.US" ownerID="1" expirationDate="7/28/2005 4:59:59 PM" status="0" private="no"/><info resourceid="domain:3" autoRenewDate="7/28/2005 4:59:59 PM" name="EXAMPLE.INFO" ownerID="1" expirationDate="7/28/2005 4:59:59 PM" status="0" private="no"/></resdata></response>'
    result = GoDaddyReseller::Connection.decode(response)
    answer = GoDaddyReseller::Domains.info_result_to_hash(result)
    
    expected = { 
      'example.com' => { :resourceid => 'domain:1', :auto_renew_date => Time.parse('7/28/2005 4:59:59 PM'), :owner_id => '1', :expiration_date => Time.parse('7/28/2005 4:59:59 PM'), :status => 0, :private => true },
      'example.us' => { :resourceid => 'domain:2', :auto_renew_date => Time.parse('7/28/2005 4:59:59 PM'), :owner_id => '1', :expiration_date => Time.parse('7/28/2005 4:59:59 PM'), :status => 0, :private => false },
      'example.info' => { :resourceid => 'domain:3', :auto_renew_date => Time.parse('7/28/2005 4:59:59 PM'), :owner_id => '1', :expiration_date => Time.parse('7/28/2005 4:59:59 PM'), :status => 0, :private => false }
    }

    answer.should == expected
  end
  
  it "creates info xml correctly" do
    result = GoDaddyReseller::Connection.xml_encode_hash({ :info => 
      ['example.com', 'example.net', 'example.org'].map { |d| {:_attributes => { :domain => d, :type => 'standard' }}} 
    })
    expected = '<info domain="example.com" type="standard" /><info domain="example.net" type="standard" /><info domain="example.org" type="standard" />'
    result.should == expected
  end
  
  it "decodes a sample poll response correclty" do
    response = '<response clTRID="reseller.0000000005"><result code="1004"><msg>messages waiting</msg></result><msgQ count="4" date="07-29-2003 13:10:31" /><resdata><REPORT><ITEM orderid="100" roid="1" riid="1" status="1" timestamp="7/29/2003 12:43:45 PM" /><ITEM orderid="100" roid="1" riid="2" status="1" timestamp="7/29/2003 12:43:45 PM" /><ITEM orderid="100" roid="1" riid="1" resourceid="domain:1" status="2" timestamp="7/29/2003 12:45:09 PM" /><ITEM orderid="100" roid="1" riid="2" resourceid="dbp:2" status="2" timestamp="7/29/2003 12:45:09PM" /></REPORT></resdata></response>'
    result = GoDaddyReseller::Connection.decode(response)
    
    answer = GoDaddyReseller::Domains.poll_result_to_order_hash(result)
    
    expected = [ { :orderid => '100', :roid => '1', :items => [ 
      { :riid => '1', :resourceid => 'domain:1', :statuses => [
        { :id => '1', :timestamp => Time.parse("7/29/2003 12:43:45 PM") },
        { :id => '2', :timestamp => Time.parse("7/29/2003 12:45:09 PM") } ]},
      { :riid => '2', :resourceid => 'dbp:2', :statuses => [
        { :id => '1', :timestamp => Time.parse("7/29/2003 12:43:45 PM") },
        { :id => '2', :timestamp => Time.parse("7/29/2003 12:45:09 PM") }] } ] }]

    answer.should == expected
  end

  it "creates manage xml correctly" do 
    result = GoDaddyReseller::Connection.xml_encode_hash(
      :manage => { 
        :cancel => { 
          :_attributes => { :type => 'immediate' },
          :id => 'dbp:2'
        }
      }
    )
    expected = '<manage><cancel type="immediate"><id>dbp:2</id></cancel></manage>'
    result.should == expected
  end

  it "creates order xml correctly" do
    result = GoDaddyReseller::Connection.xml_encode_hash(
      :order => {
        :_attributes => { :roid => 1 },
        :shopper => {
          :_attributes => {
            :user => 'createNew',
            :pwd => 'password',
            :pwdhint => 'obvious',
            :email => 'jdoe@example.com',
            :firstname => 'John',
            :lastname => 'Doe',
            :phone => '+1.4805058857',
            :dbpuser => 'createNew', # Domains by Proxy User Info, only needed if ordering private registration services
            :dbppwd => 'password',
            :dbppwdhint => 'obvious',
            :dbpemail => 'jdoe@example.com'
          }  
        },
        :item => [ 
          {
            :_attributes => {
              :productid => GoDaddyReseller::ProductTable::HASH['2 Year Domain New Registration .US'],
              :quantity => 1,
              :riid => 1
            },
            :domainRegistration => {
              :_attributes => {
                :sld => 'example',
                :tld => 'us',
                :period => 2
              },
              :nexus => {
                :_attributes => {
                  :category => "citizen of US",
                  :use => 'personal',
                  :country => 'us'
                }
              },
              :ns => [ {:_attributes => {:name => 'ns1.example.com'}}, {:_attributes => {:name => 'ns2.example.com'}} ],
              :registrant => {
                :_attributes => {
                  :fname => 'John',
                  :lname => 'Doe',
                  :org => 'Wild West Reseller',
                  :email => 'jdoe@example.com',
                  :sa1 => '14455 N. Hayden Rd.',
                  :sa2 => 'Suite 219',
                  :city => 'Scottsdale',
                  :sp => 'Arizona',
                  :pc => '85260',
                  :cc => 'United States',
                  :phone => '+1.4805058857',
                  :fax => '+1.4808241499'
                }
              },
              :admin => {
                :_attributes => {
                  :fname => 'Jane',
                  :lname => 'Doe',
                  :org => 'Wild West Reseller',
                  :email => 'janed@example.com',
                  :sa1 => '14455 N. Hayden Rd.',
                  :sa2 => 'Suite 219',
                  :city => 'Scottsdale',
                  :sp => 'Arizona',
                  :pc => '85260',
                  :cc => 'United States',
                  :phone => '+1.4805058857',
                  :fax => '+1.4808241499'
                }
              },
              :billing => {
                :_attributes => {
                  :fname => 'John',
                  :lname => 'Doe',
                  :org => 'Wild West Reseller',
                  :email => 'jdoe@example.com',
                  :sa1 => '14455 N. Hayden Rd.',
                  :sa2 => 'Suite 219',
                  :city => 'Scottsdale',
                  :sp => 'Arizona',
                  :pc => '85260',
                  :cc => 'United States',
                  :phone => '+1.4805058857',
                  :fax => '+1.4808241499'
                }
              },
              :tech => {
                :_attributes => {
                  :fname => 'John',
                  :lname => 'Doe',
                  :org => 'Wild West Reseller',
                  :email => 'jdoe@example.com',
                  :sa1 => '14455 N. Hayden Rd.',
                  :sa2 => 'Suite 219',
                  :city => 'Scottsdale',
                  :sp => 'Arizona',
                  :pc => '85260',
                  :cc => 'United States',
                  :phone => '+1.4805058857',
                  :fax => '+1.4808241499'
                }
              }
            }
          },
          {
            :_attributes => {
              :productid => GoDaddyReseller::ProductTable::HASH['Private Registration Services - API'],
              :quantity => 1,
              :riid => 2,
              :duration => 2
            },
            :domainByProxy => {
              :_attributes => { :sld => 'example', :tld => 'us'}
            } 
          }
        ]
      }
    )

    expected = '<order roid="1"><item productid="350127" quantity="1" riid="1"><domainRegistration period="2" sld="example" tld="us"><admin cc="United States" city="Scottsdale" email="janed@example.com" fax="+1.4808241499" fname="Jane" lname="Doe" org="Wild West Reseller" pc="85260" phone="+1.4805058857" sa1="14455 N. Hayden Rd." sa2="Suite 219" sp="Arizona" /><billing cc="United States" city="Scottsdale" email="jdoe@example.com" fax="+1.4808241499" fname="John" lname="Doe" org="Wild West Reseller" pc="85260" phone="+1.4805058857" sa1="14455 N. Hayden Rd." sa2="Suite 219" sp="Arizona" /><nexus category="citizen of US" country="us" use="personal" /><ns name="ns1.example.com" /><ns name="ns2.example.com" /><registrant cc="United States" city="Scottsdale" email="jdoe@example.com" fax="+1.4808241499" fname="John" lname="Doe" org="Wild West Reseller" pc="85260" phone="+1.4805058857" sa1="14455 N. Hayden Rd." sa2="Suite 219" sp="Arizona" /><tech cc="United States" city="Scottsdale" email="jdoe@example.com" fax="+1.4808241499" fname="John" lname="Doe" org="Wild West Reseller" pc="85260" phone="+1.4805058857" sa1="14455 N. Hayden Rd." sa2="Suite 219" sp="Arizona" /></domainRegistration></item><item duration="2" productid="377001" quantity="1" riid="2"><domainByProxy sld="example" tld="us" /></item><shopper dbpemail="jdoe@example.com" dbppwd="password" dbppwdhint="obvious" dbpuser="createNew" email="jdoe@example.com" firstname="John" lastname="Doe" phone="+1.4805058857" pwd="password" pwdhint="obvious" user="createNew" /></order>'

    result.should == expected
  end

end