Feature: Checkout destiny repo
  In order to get the info of the destiny repo
  As a Conversor
  I want svn to checkout the destiny repo

Scenario Outline: Checkout the SVN Destiny repo
	Given we initiate the conversor
	And there are some SVN repos like "<name>"
	And the SVN destiny Repo is "<destiny>"
    When I checkout destiny repo
    Then I should see a message "SVN destiny Checkout complete"       

  Scenarios: Checkout all the repos for tests
	| destiny | name |
	| file:///tmp/Server_Repos/git_svn-revision2 | git_svn-revision2 |
 	| file:///tmp/Server_Repos/git_svn-revision5 | git_svn-revision5 |

  
