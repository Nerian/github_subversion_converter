Feature: Checkout destiny repo
  In order to get the info of the destiny repo
  As a Conversor
  I want svn to checkout the destiny repo

Scenario Outline: Checkout the SVN Destiny repo
    Given we start the Conversor
	And there are some SVN repos like "<name>" and "<revision>"
	And the SVN destiny Repo is "<origin>" with name "<name>"
    When I checkout origin repo
    Then I should see a message "SVN Origin Checkout complete"       

  Scenarios: Checkout all the repos for tests
	| origin | name | revision |
	| http://svn.github.com/Nerian/JPovray.git | git_revision5 | revision |
	| file:///tmp/Server_Repos/git_svn-revision2 | git_svn-revision2 | revision |
 	| file:///tmp/Server_Repos/git_svn-revision5 | git_svn-revision5 | revision |

  
