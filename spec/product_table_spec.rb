require File.dirname(__FILE__) + '/spec_helper'

describe GoDaddyReseller::ProductTable do

  before(:each) do
  end
  
  it "correctly creates hash" do
    GoDaddyReseller::ProductTable::HASH['Enterprise Level DNS'].should == 375001
  end
  

end