Feature: Do conversion
  In order to update the destiny copy
  As a Conversor
  I want to commit every change from origin to destiny

Scenario Outline: Do conversion
	Given we initiate the conversor with origin "<origin>" and destiny "<destiny>" 
    #And there are some SVN repos like "<name_origin>"
	And there are some SVN repos like "<name_destiny>"
    When I checkout origin repo
	And I checkout destiny repo
	And I perform de conversion process
    Then both repos should have the same revision

  Scenarios: Origin has commit that arent on the destiny
	| origin | name_origin | name_destiny | destiny |
	| http://svn.github.com/Nerian/JPovray.git | origin | destiny | file:///tmp/Server_Repos/destiny |

  
