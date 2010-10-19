Feature: Checkout Svn origin repo
  In order to have the working directory
  As a Conversor
  I want svn checkout the svn repo                                                             

  Scenario Outline: Checkout the SVN Origin repo
    Given there are some SVN repos like "<name>" and "<revision>"
	And the SVN Origin Repo is "<origin>" with name "<name>"
    When I checkout that repo
    Then I should see a message "SVN Origin Checkout complete"       

  Scenarios: Checkout all the repos for tests
	| origin | name | revision |
	| file:///tmp/Server_Repos/git_revision5 | git_revision5 | revision |
	| file:///tmp/Server_Repos/git_svn-revision2 | git_svn-revision2 | revision |
 	| file:///tmp/Server_Repos/git_svn-revision5 | git_svn-revision5 | revision |
  
  
  


  
