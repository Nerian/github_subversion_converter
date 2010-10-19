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

Then /^I should see a message "([^"]*)"$/ do |message|
  output.messages.should include(message)
end


Given /^the SVN Origin Repo is "([^"]*)" with name "([^"]*)"$/ do |svn_repo_origin, name|
  @conversor = Conversor::Conversor.new(output, name)
  @conversor.set_svn_origin(svn_repo_origin)
end

When /^I checkout that repo$/ do
  @conversor.checkout_svn_repo()
end    
         
Given /^there are some SVN repos like "([^"]*)" and "([^"]*)"$/ do |name, revision|  
  if not File.exist?("/tmp/Server_Repos")
    system("mkdir /tmp/Server_Repos") 
  end
  system("rm -Rf /tmp/Server_Repos/"+name)
  system("svnadmin create /tmp/Server_Repos/"+name)  
end



