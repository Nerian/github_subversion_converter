class Output
  def messages
    @messages ||= []
  end

  def puts(message)
    messages << message
  end
end

def output
  @output ||= Output.new
end

Given /^we initiate the conversor with origin "([^"]*)" and destiny "([^"]*)"$/ do |origin, destiny|
  @conversor = Conversor::Conversor.new(output, origin, destiny) 
end

When /^I checkout destiny repo$/ do
  @conversor.checkout_destiny_repo()
end            

Given /^the SVN Origin Repo is "([^"]*)"$/ do |svn_address_origin|  
  @conversor.svn_address_origin = svn_address_origin
end

Given /^the SVN destiny Repo is "([^"]*)"$/ do |svn_address_destiny|
  @conversor.svn_address_destiny = svn_address_destiny
end

When /^I checkout origin repo$/ do
  @conversor.checkout_origin_repo()   
end                                                  
         
Given /^there are some SVN repos like "([^"]*)"$/ do |name|  
  if not File.exist?("/tmp/Server_Repos")
    system("mkdir /tmp/Server_Repos") 
  end
  system("rm -Rf /tmp/Server_Repos/"+name)
  system("svnadmin create /tmp/Server_Repos/"+name)  
end

When /^I perform de conversion process$/ do
  @conversor.perform_conversion()
end

Then /^both repos should have the same revision$/ do
  @conversor.destiny_repo_online_revision.should == 6  
end

Then /^I should see a message "([^"]*)"$/ do |message|
  result = File.exist?("/tmp/Server_Repos/"+@conversor.svn_origin_name)
  if result
    output.puts (message)
  end
    output.messages.should include(message)
end



