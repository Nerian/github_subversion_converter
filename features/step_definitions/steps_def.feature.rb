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

Given /^the SVN Origin Repo is "([^"]*)" with name "([^"]*)"$/ do |svn_address_origin, name|
  @conversor = Conversor::Conversor.new(output)
  @conversor.svn_address_origin = svn_address_origin
end

When /^I checkout origin repo$/ do
  @conversor.checkout_origin_repo()   
end    
         
Given /^there are some SVN repos like "([^"]*)" and "([^"]*)"$/ do |name, revision|  
  if not File.exist?("/tmp/Server_Repos")
    system("mkdir /tmp/Server_Repos") 
  end
  system("rm -Rf /tmp/Server_Repos/"+name)
  system("svnadmin create /tmp/Server_Repos/"+name)  
end

Then /^I should see a message "([^"]*)"$/ do |message|
  result = File.exist?("/tmp/Server_Repos/"+@conversor.svn_origin_name)
  if result
    output.puts (message)
  end
    output.messages.should include(message)
end



